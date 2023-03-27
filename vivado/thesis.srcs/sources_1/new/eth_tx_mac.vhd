--------------------------------------------------------------------------------
-- IEEE 802.3 Ethernet Transmit logic
-- This file contains the description for the transmit part of the Ethernet MAC.
-- That is, it takes in the raw data, puts it into a frame buffer and constructs
-- the ethernet frame to be transmitted over the RMII interface.
--
--  Notes:
--    - "Byte" and "Octets" are used synonomously in this file.
--
-- IO DESCRIPTION
--  clk: clock input
--  rst: reset MAC
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

entity eth_tx_mac is
   Port ( 
    -- WISHBONE b4 classic
        wb_i_dat        : in  std_logic_vector(31 downto 0);
        wb_o_dat        : out std_logic_vector(31 downto 0);
        wb_i_addr       : in  std_logic_vector(31 downto 0);
        wb_i_cyc        : in  std_logic;
        wb_i_lock       : in  std_logic;
        wb_i_sel        : in  std_logic;
        wb_i_we         : in  std_logic;
        wb_o_ack        : out std_logic;
        wb_o_err        : out std_logic;
        wb_o_rty        : out std_logic;
        wb_o_stall      : out std_logic;
        wb_i_stb        : in  std_logic;
    
        -- Interface
        clk_i  : in  std_logic;
        rst_i  : in  std_logic := '0';
        start         : in std_logic := '0';
        dataPresent   : out std_logic := '0';
        dataOut       : out std_logic_vector(7 downto 0);
        status        : out std_logic_vector(1 downto 0)  
    );
end eth_tx_mac;

architecture Behavioral of eth_tx_mac is


-- CONSTANTS
constant preambleSFD : std_logic_vector(63 downto 0) := x"ABAAAAAAAAAAAAAA";
constant sourceAddr  : std_logic_vector (47 downto 0) := x"BEBAEFBEADDE"; --DEADBEEFBABE
constant padding     : std_logic_vector(7 downto 0) := x"A5";

-- MAC COMMANDS
constant MAC_CONFIG             : std_logic_vector(31 downto 0) := x"13370000";

-- REGISTERS
constant MAC_DEST_ADDR_HIGH     : std_logic_vector(31 downto 0) := x"13371000";
constant MAC_DEST_ADDR_LOW      : std_logic_vector(31 downto 0) := x"13371001";
constant MAC_LEN                : std_logic_vector(31 downto 0) := x"13371002";



-- COMPONENTS
component crc
    Port (  
        CLOCK               :   in  std_logic;
        RESET               :   in  std_logic;
        DATA                :   in  std_logic_vector(7 downto 0);
        LOAD_INIT           :   in  std_logic;
        CALC                :   in  std_logic;
        D_VALID             :   in  std_logic;
        CRC_REG             :   out std_logic_vector(31 downto 0)
    );
end component;
-- END COMPONENTS


-- FRAME BUFFER
type ramType is array (1526 - 1 downto 0) of std_logic_vector(8 - 1 downto 0);
shared variable FRAME_BUFFER : ramType;

-- Used for Main fsm.
type state is (IDLE, FCS, TRANSMIT);
signal currentState, nextState, setStateFromOutside : state := IDLE;

-- Used for FCS fsm.
type fcs_state is (IDLE, FCS_START, LOAD, CALC, DATA, RESULT, FCS_ACK);
signal currentFCSState, nextFCSState : fcs_state := IDLE;



signal crcClk       : std_logic := '0';
signal crcRst       : std_logic := '0';
signal crcLoadInit  : std_logic := '0';
signal crcCalc      : std_logic := '0';
signal crcDValid    : std_logic := '0';
signal crcData      : std_logic_vector(7 downto 0);
signal crcResult    : std_logic_vector(31 downto 0);

signal crcStart     : std_logic := '0';
signal crcFinished  : std_logic := '0';
signal crcAck       : std_logic := '0';

signal startTx      : std_logic := '0';
signal startTxAck      : std_logic := '0';


signal payloadLen : std_logic_vector(15 downto 0) := (others => '0');

begin


-- -- COMPONENT MAPPINGS
FCS_CRC32 : crc
port map (
    CLOCK => crcClk,
    RESET => crcRst,
    DATA => crcData,
    LOAD_INIT => crcLoadInit,
    CALC => crcCalc,
    D_VALID => crcDValid,
    CRC_REG => crcResult
);
-- -- END COMPONENT MAPPINGS

crcClk <= clk_i;

WB_MAIN_TX : process(clk_i)
begin
    if rising_edge(clk_i) then
        
        -- Only handle data when strobe
        if startTxAck = '1' then
            startTx <= '0';
            status <= "11";
        end if;
        
        if wb_i_stb = '1' then 
            wb_o_ack <= '1';
            
            -- Ensure write enable is set.
            if wb_i_we = '1' then
                case wb_i_addr is 
                
                    -- Configure hardware.
                    when MAC_CONFIG =>
                        
                        -- Initialise the buffers.
                        if wb_i_dat(0) = '1' then
                            status <= "01";
                            -- Set preamble + SFD
                            for i in 0 to 7 loop
                                FRAME_BUFFER(i) := preambleSFD((8 * i) + 7 downto (8 * i));
                            end loop;
            
                            -- Set up source address since it's also constant
                            for i in 0 to 5 loop
                                FRAME_BUFFER(14 + i) := sourceAddr((8 * i) + 7 downto (8 * i));
                            end loop;
            
                            -- Set the padding - will override if not needed
                            for i in 0 to 45 loop
                                FRAME_BUFFER(22 + i) := padding(7 downto 0);
                            end loop;
                      
                        -- Start the transmission
                        elsif wb_i_dat(1) = '1' then
--                            setStateFromOutside <= TRANSMIT;
                            startTx <= '1';
                        end if;
                        
                        
                        
                        
                   -- Set destination MAC address (HIGH).
                    when MAC_DEST_ADDR_HIGH =>
                        
                        FRAME_BUFFER(8) := wb_i_dat(31 downto 24);
                        FRAME_BUFFER(9) := wb_i_dat(23 downto 16);
                        FRAME_BUFFER(10) := wb_i_dat(15 downto 8);
                        FRAME_BUFFER(11) :=  wb_i_dat(7 downto 0);
                        
                        status <= "00";
                    
                    
                    -- Set destination MAC address. (LOW)               
                     when MAC_DEST_ADDR_LOW =>                           
                                                                   
                        FRAME_BUFFER(12) := wb_i_dat(15 downto 8);
                        FRAME_BUFFER(13) :=  wb_i_dat(7 downto 0);
                        
                     
                     
                     -- Set the payload length
                     when MAC_LEN =>                          
                        payloadLen <= wb_i_dat(15 downto 0);      
                                                   
                        FRAME_BUFFER(21) := wb_i_dat(7 downto 0);
                        FRAME_BUFFER(20) := "00000" & wb_i_dat(10 downto 8);
                        
                     -- Setting payload
                     when others =>
                     
                        
                        -- Check to make sure we are in the safe memory range.
                        if wb_i_addr >= x"13371003" and wb_i_addr <= x"1337117A" then
                            status <= "10";
                            
                            -- 322375680 = 0x13371000.
                            FRAME_BUFFER(22 + to_integer(unsigned(wb_i_addr)) - 322375680) := wb_i_dat(31 downto 24);
                            FRAME_BUFFER(23 + to_integer(unsigned(wb_i_addr)) - 322375680) := wb_i_dat(23 downto 16);
                            FRAME_BUFFER(24 + to_integer(unsigned(wb_i_addr)) - 322375680) := wb_i_dat(15 downto 8);
                            FRAME_BUFFER(25 + to_integer(unsigned(wb_i_addr)) - 322375680) := wb_i_dat(7 downto 0);
                            
                        end if;
                        
                end case;
    
            end if;
        else
            wb_o_ack <= '0';
        end if;
    
    end if;
end process;



MAIN_TRANSITIONS : process (clk_i, rst_i)
begin
    -- Remember active low
    if rst_i = '0' then
        currentState <= IDLE;
    elsif rising_edge(clk_i) then
        currentState <= nextState;
    end if;
end process;


MAIN_FSM: process(currentState)

variable sentAmount : integer := 0;

begin
    case currentState is 
        when IDLE =>
            startTxAck <= '0';
            dataOut <= (others => '0');
            sentAmount := 0;
            if crcFinished = '1' then
                nextState <= FCS;
            elsif startTx ='1' then
                nextState <= TRANSMIT;
            else
                nextState <= IDLE;
            end if;
      
        when TRANSMIT =>
            startTxAck <= '1';
            dataPresent <= '1';
            dataOut <= FRAME_BUFFER(sentAmount);
            sentAmount := sentAmount + 1;
            
            crcStart <= '0';


            -- Add 22 to account for mac header
            if to_integer(unsigned(payloadLen)) < 46 then
                if sentAmount = 68 then
                    sentAmount := 0;
                    dataPresent <= '0';
                    if crcFinished = '1' then
                        sentAmount := 0;
                        nextState <= FCS;
                    else 
                        nextState <= IDLE;
                    end if;
                end if;
            elsif (to_integer(unsigned(payloadLen)) + 22) = sentAmount then
                sentAmount := 0;
                dataPresent <= '0';
                if crcFinished = '1' then
                    sentAmount := 0;
                    nextState <= FCS;
                else 
                    nextState <= IDLE;
                end if;
            end if;
            

        when FCS =>
            -- Calculate the CRC32 and add it to the FRAME_BUFFER
            startTxAck <= '0';
            crcAck <= '1';
            dataPresent <= '1';
            dataOut <= crcResult((8 * sentAmount) + 7 downto (8 * sentAmount));
            sentAmount := sentAmount + 1;
            
            if sentAmount = 4 then
                crcAck <= '0';
                sentAmount := 0;
                dataPresent <= '0';
                nextState <= IDLE;
            else 
                nextState <= FCS;
            end if;

   
    end case;

end process;


FCS_TRANSITIONS : process (clk_i, rst_i)
begin
    -- Remember active low
    if rst_i = '0' then
        currentFCSState <= IDLE;
    elsif rising_edge(clk_i) then
        currentFCSState <= nextFCSState;
    end if;
end process;

FCS_FSM: process(currentFCSState) 
variable bytesAnalysed : integer := 0;

begin
    case currentFCSState is 
        when IDLE =>
            if crcStart = '1' then
                nextFCSState <= FCS_START;
            else
                nextFCSState <= IDLE;
            end if;
            
        when FCS_START =>
            
            crcDValid <= '0';
            crcLoadInit <= '0';
            bytesAnalysed := 0;
            crcCalc <= '0';
            crcRst <= '1';
            crcFinished <= '0';
            nextFCSState <= LOAD;
        
        when LOAD =>
            crcRst <= '0';
            crcLoadInit <= '1';
            nextFCSState <= CALC;
        when CALC => 
            crcLoadInit <= '0';
            crcCalc <= '1';
            nextFCSState <= DATA;

        when DATA =>
            crcData <= FRAME_BUFFER(bytesAnalysed + 8);
            crcDValid <= '1';
            
            bytesAnalysed := bytesAnalysed + 1;

            -- Only change states after added all packets.
            if to_integer(unsigned(payloadLen)) < 46 then
                if bytesAnalysed = 60 then -- Remember to not include preamble or SFD
                    bytesAnalysed := 0;
                    nextFCSState <= RESULT;
                end if;
            elsif (to_integer(unsigned(payloadLen)) + 14) = bytesAnalysed then
                bytesAnalysed := 0;
                nextFCSState <= RESULT;
            end if;
           

        when RESULT =>
            crcCalc <= '0';
            crcDValid <= '0';
            crcFinished <= '1';
            nextFCSState <= FCS_ACK;
            
        when FCS_ACK =>
            if crcAck = '1' then
                crcFinished <= '0';
                nextFCSState <= IDLE;
            end if;

        when others => -- Should never reach here, but incase
            nextFCSState <= IDLE;
    end case;

end process;





end Behavioral;
