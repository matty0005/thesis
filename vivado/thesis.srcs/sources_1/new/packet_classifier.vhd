--------------------------------------------------------------------------------
-- Packet classifier for FPGA firewall.
-- Uses SPI to configure and monitor
--
-- SPI packet layout
-- Address (1) | Wildcard (1) | Dest Addr (4) | Source Addr (4) | Dest Port (2) | Source Port (2) | Protocol (1)
--           
--
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

use work.utils_pkg.ALL;

entity packet_classifier is
  Port (
    clk:  in std_logic;
    rst:  in std_logic;
    valid: out std_logic; -- Output "forward" is valid when 1. 
    forward: out std_logic;
    ignore_count: out std_logic;
    
    packet_in: in std_logic_vector(1 downto 0);
    packet_valid: in std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic;
    
    test_out: out std_logic_vector(7 downto 0)
   );
end packet_classifier;

architecture Behavioral of packet_classifier is

-- CONSTANTS
constant ruleSize : integer := 8;


-- Classifier rules memeory
type ramType is array (ruleSize - 1 downto 0) of std_logic_vector(112 - 1 downto 0);
shared variable RULES_MEMORY : ramType := (others => (others => '0'));

type classifer_state is (PRE_IDLE, IDLE, PACKET_TYPE, IP_DEST, IP_SOURCE, PORT_DEST, PORT_SOURCE, PROTO);
signal pcState : classifer_state := IDLE;

signal spi_mosi_data : std_logic_vector(119 downto 0); -- 14 bytes = 112 bits for data + 8 bits addr + 8bits wildcard  (1byte)

-- Hard set max count of rules to 32. Each bit represents if the rule is still valid. 
-- After iteratting over each field, if the value is non-zero, it is allowed through.
signal rulesMatch : std_logic_vector(31 downto 0) := (others => '0');

constant PIPE_SIZE : integer := 64 - 1;
signal data_pipe : std_logic_vector(PIPE_SIZE downto 0) := x"0000000000000000";

signal pc_forward : std_logic;
signal pc_valid : std_logic;

begin

data_processer: process(clk)
begin
    if rising_edge(clk) then
        data_pipe <= data_pipe(PIPE_SIZE - 2 downto 0) & packet_in;
    end if;
end process;

test_out(1 downto 0) <= data_pipe(1 downto 0);

test_out(7) <= clk;
test_out(2) <= packet_valid;

forward <= pc_forward;
valid <= pc_valid;
test_out(5 downto 4) <= pc_forward & pc_valid;
test_out(6) <= rst;

classifier_new : process(clk, rst)
variable stateCounter : integer := 0;
variable ipHeaderLen : std_logic_vector(3 downto 0);
variable ipProto : std_logic_vector(7 downto 0);
begin
    if rising_edge(clk) then 
        case pcState is
                when  PRE_IDLE => 
                    pcState <= IDLE;
                    pc_valid <= '0';
                    pc_forward <= '0';
                when IDLE => 
                   
                    --  Wait for valid packet with Preamble + SFD: 55555555555555D5
                    if data_pipe = x"5555555555555557" and packet_valid = '1' then
                        pcState <= PACKET_TYPE;
                    end if;
                    pc_valid <= '0';
                    pc_forward <= '0';
                    ignore_count <= '0';
                    
                    rulesMatch <= (others => '0');
                when PACKET_TYPE =>
                    -- Need to wait for dest and src mac addr = 12 bytes
                    if stateCounter = (12 * 4 + (2 * 4) - 1) then
                    
                            -- Check that packet is type IPV4
                            if  eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = x"0800" then 
                                pcState <= PROTO;                               
                                
                            elsif eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = x"0806" then -- ARP packet - forward. 
                                pc_valid <= '1';
                                pc_forward <= '1';
                                ignore_count <= '1';
                                pcState <= PRE_IDLE; -- Could be an issue if "D555555555555555" is input into the packet. 
                            else -- Don't forward unknown packet.
                                pc_valid <= '1';
                                pc_forward <= '1';
                                ignore_count <= '1';
                                pcState <= PRE_IDLE; -- Could be an issue if "D555555555555555" is input into the packet. 
                            end if;
                            stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when PROTO =>
                
                    -- Get IHL 
                    if stateCounter = (4) then
                        ipHeaderLen := eth_swap_bits(data_pipe(7 downto 0))(3 downto 0);
                    end if;
                    
                    -- Need to wait for 64bits + 8 bits = 9 bytes - 1 byte wide.
                    if stateCounter = (9 * 4 + (1 * 4) - 1) then
                    
                            -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 0) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif eth_swap_bits(data_pipe(7 downto 0)) = RULES_MEMORY(i)(7 downto 0) then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            
                            end if;
                        end loop;
                    
                        ipProto := eth_swap_bits(data_pipe(7 downto 0));
                        
                        pcState <= IP_SOURCE;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when IP_SOURCE =>
                    -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                    if stateCounter = (2 * 4 + (4 * 4) - 1) then
                        
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 3) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif eth_swap_bits(data_pipe(31 downto 24)) & eth_swap_bits(data_pipe(23 downto 16)) & eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = RULES_MEMORY(i)(71 downto 40) and rulesMatch(i) = '1' then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            end if;
                        end loop;
                        
                        pcState <= IP_DEST;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when IP_DEST =>
                    -- Need to wait for 16bits = 2 bytes - 4 byte wide.
                    if stateCounter = ((4 * 4) - 1) then
                    
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 4) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif eth_swap_bits(data_pipe(31 downto 24)) & eth_swap_bits(data_pipe(23 downto 16)) & eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = RULES_MEMORY(i)(103 downto 72) and rulesMatch(i) = '1' then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            end if;
                        end loop;
                        
                        pcState <= PORT_SOURCE;
                        stateCounter := 0;
                        
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                
                    
                when PORT_SOURCE =>
                
                    -- If proto was either UDP or TCP, need to wait (ipHeaderLen - 20) + 0bytes - 2 bytes wide. 
                    if ipProto /= x"06" and ipProto /= x"11" and ipProto /= x"01" then -- If not TCP or UDP forward - no ports.
                        pc_valid <= '1';
                        pc_forward <= '0';
                        pcState <= PRE_IDLE;
                    -- Check if ICMP then determine if it matches the other rules.
                    elsif ipProto = x"01" then
                        
                        if rulesMatch(7 downto 0) = x"00" then
                            pc_valid <= '1';
                            pc_forward <= '0';
                            
                        else
                            pc_valid <= '1';
                            pc_forward <= '1';
                        end if;
                                                
                        pcState <= PRE_IDLE;
                        stateCounter := 0;
                    else 
                        -- wait for bytes. 
                        -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                        if stateCounter = ((unsigned(ipHeaderLen) - 20) * 4 + (2 * 4) - 1) then
                        
                            -- Check fields
                            for i in 0 to ruleSize-1 loop
                                if RULES_MEMORY(i)(104 + 1) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                    rulesMatch(i) <= '1';
                                elsif eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = RULES_MEMORY(i)(23 downto 8) and rulesMatch(i) = '1' then
                                    rulesMatch(i) <= '1';
                                else 
                                    rulesMatch(i) <= '0';
                                end if;
                            end loop;
                            
                            pcState <= PORT_DEST;
                            stateCounter := 0;
                        else
                            stateCounter := stateCounter + 1;
                        end if;
                    end if;
                
                    
                when PORT_DEST =>
                    -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                    if stateCounter = (0 * 4 + (2 * 4) - 1) then
                    
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 2) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif eth_swap_bits(data_pipe(15 downto 8)) & eth_swap_bits(data_pipe(7 downto 0)) = RULES_MEMORY(i)(39 downto 24) and rulesMatch(i) = '1' then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            end if;
                        end loop;
                        
                        if rulesMatch(7 downto 0) = x"00" then
                            pc_valid <= '1';
                            pc_forward <= '0';
                        else
                            pc_valid <= '1';
                            pc_forward <= '1';
                        end if;
                        
                        pcState <= PRE_IDLE;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
        end case;
    end if;
end process;

--test_port <= RULES_MEMORY(0) & x"00";

spi_input : process(spi_clk, rst)
variable spiCounter : integer := 0;
begin
    if rst = '1' then
        spiCounter := 0;
    elsif rising_edge(spi_clk) and spi_csn = '0' then
        spi_mosi_data <= spi_mosi_data(118 downto 0) & spi_mosi;
                        
        if spiCounter = 119 then
            -- Save the contents in the vector to the memory
            -- Needs to be 118 since the result wont be ready in time. 
            RULES_MEMORY(to_integer(unsigned(spi_mosi_data(118 downto 111)))) := spi_mosi_data(110 downto 0) & spi_mosi;
            spiCounter := 0;
        else 
            spiCounter := spiCounter + 1;
        end if;
    end if;
end process;

end Behavioral;
