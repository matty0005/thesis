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
    
    packet_in: in std_logic_vector(7 downto 0);
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
shared variable RULES_MEMORY : ramType;

type classifer_state is (IDLE, IP_DEST, IP_SOURCE, PORT_DEST, PORT_SOURCE, PROTO);
signal classiferState : classifer_state := IDLE;

signal spi_mosi_data : std_logic_vector(119 downto 0); -- 14 bytes = 112 bits for data + 8 bits addr  (1byte)

-- Hard set max count of rules to 32. Each bit represents if the rule is still valid. 
-- After iteratting over each field, if the value is non-zero, it is allowed through.
signal rulesMatch : std_logic_vector(31 downto 0) := (others => '0');

-- Stores the most recent 4 bytes incoming from the network interface. 
signal incommingDataPipe : std_logic_vector(31 downto 0);

begin


classifier : process(clk)
variable stateCounter : integer := 0;
begin
    if rising_edge(clk) and packet_valid = '1' then
    
        stateCounter := stateCounter + 1;
        
        -- determine if to continue or forward data.
        case classiferState is
            when IDLE =>
                valid  <= '0'; 
                forward <= '0';
                classiferState <= IDLE;
            when IP_DEST =>
                if stateCounter = 4 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(4) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif incommingDataPipe(31 downto 0) = RULES_MEMORY(i)(103 downto 72) then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= IP_SOURCE;
                    stateCounter := 0;
                end if;
        
                classiferState <= IP_DEST;
                
           when IP_SOURCE =>
                if stateCounter = 4 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(3) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif incommingDataPipe(31 downto 0) = RULES_MEMORY(i)(71 downto 40)  and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PORT_DEST;
                    stateCounter := 0;
                end if;
        
                classiferState <= IP_SOURCE;
                
            when PORT_DEST =>
                if stateCounter = 2 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(2) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif incommingDataPipe(15 downto 0) = RULES_MEMORY(i)(39 downto 24) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PORT_SOURCE;
                    stateCounter := 0;
                end if;
        
                classiferState <= PORT_DEST;
                
            when PORT_SOURCE =>
                if stateCounter = 2 then
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(1) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif incommingDataPipe(15 downto 0) = RULES_MEMORY(i)(23 downto 8) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                
                    classiferState <= PROTO;
                    stateCounter := 0;
                end if;
        
                classiferState <= PORT_SOURCE;
                
            when PROTO =>
                    
                    -- Check fields
                    for i in 0 to ruleSize-1 loop
                        if RULES_MEMORY(i)(0) = '1' and rulesMatch(i) = '1' then -- If wildcard entry is here accept by default
                            rulesMatch(i) <= '1';
                        elsif incommingDataPipe(7 downto 0) = RULES_MEMORY(i)(7 downto 0) and rulesMatch(i) = '1' then
                            rulesMatch(i) <= '1';
                        else 
                            rulesMatch(i) <= '0';
                        end if;
                    end loop;
                    
                    if rulesMatch = x"00000000" then
                        -- No match
                        valid  <= '1'; 
                        forward <= '0';
                    else
                        -- Match
                        valid  <= '1'; 
                        forward <= '1';
                    end if;
                
                    classiferState <= IDLE;
                    stateCounter := 0;

                
        end case;
    end if;
end process;





spi_input : process(spi_clk)
begin
    if rising_edge(spi_clk) and spi_csn = '0' then
        spi_mosi_data <= spi_mosi_data(110 downto 0) & spi_mosi;
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
                
        if spiCounter = 104 then
            -- Save the contents in the vector to the memory
            RULES_MEMORY(to_integer(unsigned(spi_mosi_data(111 downto 104)))) := spi_mosi_data(103 downto 0);
            spiCounter := 0;
        end if;
    end if;
end process;


end Behavioral;
