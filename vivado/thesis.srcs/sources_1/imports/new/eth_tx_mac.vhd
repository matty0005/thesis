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
        start         : out std_logic := '0';
        dataPresent   : out std_logic := '0';
        dataOut       : out std_logic_vector(7 downto 0);
        status        : out std_logic_vector(1 downto 0)
--        statusa        : out std_logic_vector(1 downto 0);  
--        statusb        : out std_logic_vector(7 downto 0)
    );
end eth_tx_mac;

architecture Behavioral of eth_tx_mac is


-- CONSTANTS
constant preambleSFD : std_logic_vector(63 downto 0) := x"D555555555555555";
--constant preambleSFD : std_logic_vector(63 downto 0) := x"ABAAAAAAAAAAAAAA";
constant sourceAddr  : std_logic_vector (47 downto 0) := x"BEBAEFBEADDE"; --DEADBEEFBABE
constant padding     : std_logic_vector(7 downto 0) := x"00"; -- Can change to A5

-- MAC COMMANDS
constant MAC_CONFIG             : std_logic_vector(31 downto 0) := x"13370000";

-- REGISTERS
constant MAC_DEST_ADDR_HIGH     : std_logic_vector(31 downto 0) := x"13371000";
constant MAC_DEST_ADDR_LOW      : std_logic_vector(31 downto 0) := x"13371004";
constant MAC_LEN                : std_logic_vector(31 downto 0) := x"13371008";
constant MAC_DAT_SIZE           : std_logic_vector(31 downto 0) := x"13371000"; -- 0C




-- COMPONENTS
component crc
    Port (  
        CLOCK               :   in  std_logic;
        RESET               :   in  std_logic;
        DATA                :   in  std_logic_vector(7 downto 0);
        LOAD_INIT           :   in  std_logic;
        CALC                :   in  std_logic;
        D_VALID             :   in  std_logic;
        CRC_REG             :   out std_logic_vector(31 downto 0);
        CRC                 :   out std_logic_vector(7 downto 0);
        CRC_VALID           :   out std_logic
    );
end component;
-- END COMPONENTS


-- FRAME BUFFER
type ramType is array (1526 - 1 downto 0) of std_logic_vector(8 - 1 downto 0);
shared variable FRAME_BUFFER : ramType;

-- Used for Main fsm.
type state is (IDLE, FCS, TRANSMIT, RESET_FCS, LOAD_FCS, NEXT_IDLE);
signal currentState, nextState, setStateFromOutside : state := IDLE;

-- Used for FCS fsm.
type fcs_state is (IDLE, FCS_START, LOAD, CALC, DATA, RESULT, FCS_ACK);
signal currentFCSState, nextFCSState : fcs_state := IDLE;



signal crcClk       : std_logic := '0';
signal crcRst       : std_logic := '0';
signal crcLoadInit  : std_logic := '0';
signal crcCalc      : std_logic := '0';
signal crcDValid    : std_logic := '0';
signal crcValid    : std_logic := '0';
signal crcData      : std_logic_vector(7 downto 0);
signal crcReg8      : std_logic_vector(7 downto 0);
signal crcReg    : std_logic_vector(31 downto 0);
signal crcResult    : std_logic_vector(31 downto 0);

signal crcStart     : std_logic := '0';
signal crcFinished  : std_logic := '0';
signal crcAck       : std_logic := '0';

signal startTx      : std_logic := '0';
signal startTxAck      : std_logic := '0';

signal crcIdle      : std_logic := '0';


signal payloadLen : std_logic_vector(15 downto 0) := (others => '0');


signal nextCrcData, repeatByte: std_logic_vector(7 downto 0);


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
    CRC_REG => crcReg,
    CRC => crcReg8,
    CRC_VALID => crcValid
);
-- -- END COMPONENT MAPPINGS

crcClk <= not clk_i;

WB_MAIN_TX : process(clk_i)
variable virtAddr : integer := 0;
begin
    if rising_edge(clk_i) then
        
        -- Only handle data when strobe
        if startTxAck = '1' then
            startTx <= '0';
        end if;
        
        if wb_i_stb = '1' then 
            wb_o_ack <= '1';
            
            -- Ensure write enable is set.
            if wb_i_we = '0' then
                
                if wb_i_addr = MAC_DAT_SIZE then                 
                        wb_o_dat <= x"0000" & payloadLen;
                else  
                    if wb_i_addr >= x"13371004" and wb_i_addr <= x"1337117A" then
                        
                        -- 322375680 = 0x13371000.
                        virtAddr := to_integer(4 * (unsigned(wb_i_addr(15 downto 0)) - 4100));
                        
                        wb_o_dat <= FRAME_BUFFER(8 + virtAddr) &  FRAME_BUFFER(9 + virtAddr) & FRAME_BUFFER(10 + virtAddr) & FRAME_BUFFER(11 + virtAddr);
                        
                    end if;
                end if;                      

            elsif wb_i_we = '1' then
                
                -- Configure hardware.
                if  wb_i_addr = MAC_CONFIG then
                    
                    -- Initialise the buffers.
                    if wb_i_dat(0) = '1' then
                        status <= "01";
                  
                        -- Set preamble + SFD
                        for i in 0 to 7 loop
                            FRAME_BUFFER(i) := preambleSFD((8 * i) + 7 downto (8 * i));
                        end loop;
        
                
                    -- Start the transmission
                    elsif wb_i_dat(1) = '1' then
--                            setStateFromOutside <= TRANSMIT;
                        startTx <= '1';
                        status <= "10";
                    elsif wb_i_dat = x"00000000" then
                        startTx <= '0';
                        status <= "00";
                    end if;
                 elsif  wb_i_addr = MAC_DAT_SIZE then  

                    payloadLen <= wb_i_dat(15 downto 0); 
                end if;
                
                -- Check to make sure we are in the safe memory range.
                if wb_i_addr >= x"13371004" and wb_i_addr <= x"13376410" then
                    
                    -- 322375680 = 0x13371000.
                    virtAddr := to_integer((unsigned(wb_i_addr(15 downto 0)) - 4100));
                    
                    FRAME_BUFFER(8 + virtAddr) := wb_i_dat(31 downto 24);
                    FRAME_BUFFER(9 + virtAddr) := wb_i_dat(23 downto 16);
                    FRAME_BUFFER(10 + virtAddr) := wb_i_dat(15 downto 8);
                    FRAME_BUFFER(11 + virtAddr) := wb_i_dat(7 downto 0);
                    
                end if;
                        
    
            end if;
        else
            wb_o_ack <= '0';
        end if;
    
    end if;
end process;


MAIN_FSM: process(clk_i)

variable sentAmount : integer := 0;

begin
    if rst_i = '0' then
        nextState <= IDLE;
    elsif rising_edge(clk_i) then
        case nextState is 
            when IDLE =>
                startTxAck <= '0';
                dataOut <= (others => '0');
                sentAmount := 0;
                if startTx ='1' then
                    nextState <= RESET_FCS;
                    startTxAck <= '1';
                else
                    nextState <= IDLE;
                end if;
          
            when RESET_FCS => 
                crcDValid <= '0';
                crcLoadInit <= '0';
                crcCalc <= '0';
                crcRst <= '1';
                nextState <= LOAD_FCS;
                
            when LOAD_FCS =>
                crcRst <= '0';
                crcLoadInit <= '1';
                nextState <= TRANSMIT;
                
                   
            when TRANSMIT =>
                
                -- Ignore preamble + SFD
                start <= '1';
                crcData <= FRAME_BUFFER(sentAmount);
                if sentAmount > 7 then
                    crcLoadInit <= '0';
                    crcCalc <= '1';
                    
                    crcDValid <= '1';
                end if;
                
                dataPresent <= '1';
                dataOut <= FRAME_BUFFER(sentAmount);
                sentAmount := sentAmount + 1;
                
    
    
                -- Add 22 to account for mac header
                if to_integer(unsigned(payloadLen)) < 46 then
                    
                    if sentAmount = 69 then
                        sentAmount := 0;
                        dataPresent <= '0';
                        crcCalc <= '0';

                        nextState <= FCS;
       
                    end if;
                elsif (to_integer(unsigned(payloadLen)) + 22) = sentAmount then
                    sentAmount := 0;
                    dataPresent <= '0';
                    crcCalc <= '0';
                    
                    nextState <= FCS;                    
                end if;
                
                nextCrcData <= crcReg8;
                
    
            when FCS =>
                -- Transmitting has already started - can disable flag now. 
                start <= '0';

                -- Calculate the CRC32 and add it to the FRAME_BUFFER
                startTxAck <= '0';
                dataPresent <= '1';
                
                crcDValid <= '1';
                crcCalc <= '0';
                
                dataOut <= nextCrcData;
     
                nextCrcData <= crcReg8;
                sentAmount := sentAmount + 1;
                
                if sentAmount = 4 then
                    sentAmount := 0;
                    repeatByte <= nextCrcData;
                    nextState <= NEXT_IDLE;
                else 
                    nextState <= FCS;
                end if;
                
            when NEXT_IDLE => 
                dataOut <= repeatByte;
                nextState <= IDLE;
                dataPresent <= '0';
           
        end case;
     
        end if;
end process;


end Behavioral;
