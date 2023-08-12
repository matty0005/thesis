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

entity packet_classifier is
  Port (
    clk:  in std_logic;
    rst:  in std_logic;
    valid: out std_logic; -- Output "forward" is valid when 1. 
    forward: out std_logic;
    
    packet_in: in std_logic_vector(1 downto 0);
    packet_valid: in std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic
   );
end packet_classifier;

architecture Behavioral of packet_classifier is

-- CONSTANTS
constant ruleSize : integer := 8;


-- Classifier rules memeory
type ramType is array (ruleSize - 1 downto 0) of std_logic_vector(112 - 1 downto 0);
shared variable RULES_MEMORY : ramType := (others => (others => '0'));

type classifer_state is (IDLE, PACKET_TYPE, IP_DEST, IP_SOURCE, PORT_DEST, PORT_SOURCE, PROTO);
signal pcState : classifer_state := IDLE;

signal spi_mosi_data : std_logic_vector(119 downto 0); -- 14 bytes = 112 bits for data + 8 bits addr + 8bits wildcard  (1byte)

-- Hard set max count of rules to 32. Each bit represents if the rule is still valid. 
-- After iteratting over each field, if the value is non-zero, it is allowed through.
signal rulesMatch : std_logic_vector(31 downto 0) := (others => '0');

constant PIPE_SIZE : integer := 64 - 1;
signal data_pipe : std_logic_vector(PIPE_SIZE downto 0) := x"0000000000000000";

begin

data_processer: process(clk)
begin
    if rising_edge(clk) then
        data_pipe <= data_pipe(PIPE_SIZE - 2 downto 0) & packet_in;
    end if;
end process;

classifier_new : process(clk)
variable stateCounter : integer := 0;
variable ipHeaderLen : std_logic_vector(3 downto 0);
variable ipProto : std_logic_vector(7 downto 0);
begin
    if rising_edge(clk) then 
        case pcState is
                when IDLE => 
                   
                    --  Wait for valid packet with Preamble + SFD
                    if data_pipe = x"D555555555555555" and packet_valid = '1' then
                        pcState <= PACKET_TYPE;
                    end if;
                    valid <= '0';
                    forward <= '0';
                    rulesMatch <= (others => '0');
                when PACKET_TYPE =>
                    -- Need to wait for dest and src mac addr = 12 bytes
                    if stateCounter = (12 * 4 + (2 * 4)) then
                    
                            -- Check that packet is type IPV4
                            if data_pipe(15 downto 0) = x"0800" then 
                                pcState <= PROTO;
                                
                            elsif data_pipe(15 downto 0) = x"0806" then -- ARP packet - forward. 
                                valid <= '1';
                                forward <= '1';
                                pcState <= IDLE; -- Could be an issue if "D555555555555555" is input into the packet. 
                            else -- Don't forward unknown packet.
                                valid <= '1';
                                forward <= '0';
                                pcState <= IDLE; -- Could be an issue if "D555555555555555" is input into the packet. 
                            end if;
                            stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when PROTO =>
                
                    -- Get IHL 
                    if stateCounter = (4) then 
                        ipHeaderLen := data_pipe(3 downto 0);
                    end if;
                    -- Need to wait for 64bits + 8 bits = 9 bytes - 1 byte wide.
                    if stateCounter = (9 * 4 + (1 * 4)) then
                    
                            -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 0) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif data_pipe(7 downto 0) = RULES_MEMORY(i)(7 downto 0) and rulesMatch(i) = '1' then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            end if;
                        end loop;
                        
                        ipProto := data_pipe(7 downto 0);
                        
                        pcState <= IP_DEST;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when IP_DEST =>
                    -- Need to wait for 16bits = 2 bytes - 4 byte wide.
                    if stateCounter = (2 * 4 + (4 * 4)) then
                    
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 4) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif data_pipe(31 downto 0) = RULES_MEMORY(i)(103 downto 72) then
                                rulesMatch(i) <= '1';
                            else 
                                rulesMatch(i) <= '0';
                            end if;
                        end loop;
                        
                        pcState <= IP_SOURCE;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
                    
                when IP_SOURCE =>
                    -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                    if stateCounter = (0 * 4 + (4 * 4)) then
                    
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 3) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                rulesMatch(i) <= '1';
                            elsif data_pipe(31 downto 0) = RULES_MEMORY(i)(71 downto 40) and rulesMatch(i) = '1' then
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
                    
                when PORT_DEST =>
                
                    -- If proto was either UDP or TCP, need to wait (ipHeaderLen - 20) + 0bytes - 2 bytes wide. 
                    if ipProto /= x"06" and ipProto /= x"11" then -- If not TCP or UDP forward - no ports.
                        valid <= '1';
                        forward <= '1';
                        pcState <= IDLE;
                    else 
                        -- wait for bytes. 
                        -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                        if stateCounter = ((unsigned(ipHeaderLen) - 20) * 4 + (2 * 4)) then
                        
                            -- Check fields
                            for i in 0 to ruleSize-1 loop
                                if RULES_MEMORY(i)(104 + 2) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                    rulesMatch(i) <= '1';
                                elsif data_pipe(15 downto 0) = RULES_MEMORY(i)(39 downto 24) and rulesMatch(i) = '1' then
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
                    end if;
                
                    
                when PORT_SOURCE =>
                    -- Need to wait for 0bits = 0 bytes - 4 byte wide.
                    if stateCounter = (0 * 4 + (2 * 4)) then
                    
                        -- Check fields
                        for i in 0 to ruleSize-1 loop
                            if RULES_MEMORY(i)(104 + 1) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                                valid <= '1';
                                forward <= '1';
                            elsif data_pipe(15 downto 0) = RULES_MEMORY(i)(23 downto 8) and rulesMatch(i) = '1' then
                                valid <= '1';
                                forward <= '1';
                            else 
                                valid <= '1';
                                forward <= '0';
                            end if;
                        end loop;
                        
                        pcState <= IDLE;
                        stateCounter := 0;
                    else
                        stateCounter := stateCounter + 1;
                    end if;
        end case;
    end if;
end process;

--test_port <= RULES_MEMORY(0) & x"00";

spi_input : process(spi_clk)
begin
    if rising_edge(spi_clk) and spi_csn = '0' then
        spi_mosi_data <= spi_mosi_data(118 downto 0) & spi_mosi;
    end if;
end process;

spi_control : process(spi_clk, rst)

variable ruleAddr : std_logic_vector(7 downto 0) := x"00";
variable spiCounter : integer := 0;

begin
    if rst = '1' then
        spiCounter := 0;
    elsif rising_edge(spi_clk) and spi_csn = '0' then
        
        spiCounter := spiCounter + 1;
                
        if spiCounter = 121 then
            -- Save the contents in the vector to the memory
            RULES_MEMORY(to_integer(unsigned(spi_mosi_data(119 downto 112)))) := spi_mosi_data(111 downto 0);
            spiCounter := 0;
        end if;
        
        
    end if;
end process;


end Behavioral;
