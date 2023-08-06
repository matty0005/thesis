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
    
    packet_in: in std_logic_vector(31 downto 0);
    packet_valid: in std_logic;
    
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic;
    
    test_port : out std_logic_vector(119 downto 0)
   );
end packet_classifier;

architecture Behavioral of packet_classifier is

-- CONSTANTS
constant ruleSize : integer := 8;


-- Classifier rules memeory
type ramType is array (ruleSize - 1 downto 0) of std_logic_vector(112 - 1 downto 0);
shared variable RULES_MEMORY : ramType := (others => (others => '0'));

type classifer_state is (IP_DEST, IP_SOURCE, PORT_DEST, PORT_SOURCE, PROTO);
signal classiferState : classifer_state := IP_DEST;

signal spi_mosi_data : std_logic_vector(119 downto 0); -- 14 bytes = 112 bits for data + 8 bits addr + 8bits wildcard  (1byte)

-- Hard set max count of rules to 32. Each bit represents if the rule is still valid. 
-- After iteratting over each field, if the value is non-zero, it is allowed through.
signal rulesMatch : std_logic_vector(31 downto 0) := (others => '0');

begin


classifier : process(clk)
variable stateCounter : integer := 0;
begin
    if rising_edge(clk) and packet_valid = '0' then -- reset state
        valid  <= '0'; 
        rulesMatch <= (others => '0');
        classiferState <= IP_DEST;
        stateCounter := 0;
        
    elsif rising_edge(clk) and packet_valid = '1' then
    
        stateCounter := stateCounter + 1;
        
        test_port <= rulesMatch(3 downto 0) & std_logic_vector(to_unsigned(stateCounter, 4)) & packet_in & RULES_MEMORY(0)(71 downto 0) & "00000000";
        valid  <= '0'; 
        -- determine if to continue or forward data.
        case classiferState is
            when IP_DEST =>
                if stateCounter = 4 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(104 + 4) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif packet_in(31 downto 0) = RULES_MEMORY(i)(103 downto 72) then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= IP_SOURCE;
                    stateCounter := 0;
                else 
                    classiferState <= IP_DEST;
                end if;
        
           when IP_SOURCE =>
                if stateCounter = 4 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(104 + 3) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif packet_in(31 downto 0) = RULES_MEMORY(i)(71 downto 40) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PORT_DEST;
                    stateCounter := 0;
                else
                    classiferState <= IP_SOURCE;
                end if;
                        
            when PORT_DEST =>
                if stateCounter = 2 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(104 + 2) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif packet_in(15 downto 0) = RULES_MEMORY(i)(39 downto 24) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PORT_SOURCE;
                    stateCounter := 0;
                else
                    classiferState <= PORT_DEST;
                end if;

            when PORT_SOURCE =>
                if stateCounter = 2 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(104 + 1) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif packet_in(15 downto 0) = RULES_MEMORY(i)(23 downto 8) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PROTO;
                    stateCounter := 0;
                else 
                    classiferState <= PORT_SOURCE;
                end if;
   
            when PROTO =>
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(104 + 0) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif packet_in(7 downto 0) = RULES_MEMORY(i)(7 downto 0) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                    
                    -- Forward handled outside of the process statement.
                    valid  <= '1'; 
                
                    classiferState <= IP_DEST;
                    stateCounter := 0;

                
        end case;
    end if;
end process;

forward <= '0' when rulesMatch = x"00000000" else '1';

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
