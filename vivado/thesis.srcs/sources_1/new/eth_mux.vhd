--------------------------------------------------------------------------------
-- Essentially a multiplexor that handles the ethernet packets coming in and going out. 
-- Packets that have the 
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


entity eth_mux is
    Port (
    
    -- Classifier 
    clk:  in std_logic;
    rst:  in std_logic;
    spi_clk: in std_logic;
    spi_mosi: in std_logic;
    spi_miso: out std_logic;
    spi_csn: in std_logic;
    
    eth_clk: in std_logic;

    -- Phy Chip Nexys
    eth0_io_mdc: inout std_logic;
    eth0_io_mdio: inout std_logic;
    eth0_o_rstn: out std_logic;
    eth0_io_crs_dv: in std_logic;
    eth0_i_rxerr: in std_logic;
    eth0_io_rxd: in std_logic_vector(1 downto 0);
    eth0_o_txen: out std_logic;
    eth0_o_txd: out std_logic_vector(1 downto 0);
    eth0_o_refclk: out std_logic;
    eth0_i_intn: in std_logic;
    
    
    -- Phy Chip PMOD
    eth1_io_mdc: inout std_logic;
    eth1_io_mdio: inout std_logic;
    eth1_io_crs_dv: in std_logic;
    eth1_io_rxd: in std_logic_vector(1 downto 0);
    eth1_o_txen: out std_logic;
    eth1_o_txd: out std_logic_vector(1 downto 0);
    eth1_o_refclk: out std_logic;
    eth1_i_intn: in std_logic
    );
end eth_mux;

architecture Behavioral of eth_mux is

-- FSMs 
type packetStates is (IDLE, FORWARD, DROP);
signal incomingState : packetStates := IDLE;

signal OUTGOING_BUFF_0 : std_logic_vector((1526 * 8) - 1 downto 0);
signal INCOMING_BUFF_1 : std_logic_vector((1526 * 8) - 1 downto 0);

signal classifier_valid : std_logic := '0';
signal classifier_forward : std_logic := '0';
signal classifier_packet_valid : std_logic := '0';


component packet_classifier is 
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
    spi_csn: in std_logic
    
    
   );
end component; 


begin


pk : packet_classifier 
port map (
    clk => clk,
    rst => rst,
    
    spi_clk => spi_clk,
    spi_mosi => spi_mosi,
    spi_miso => spi_miso,
    spi_csn => spi_csn,
    
    valid => classifier_valid,
    forward => classifier_forward,
    packet_in => INCOMING_BUFF_1(31 downto 0),
    packet_valid => classifier_packet_valid
);



-- Static assignemnts.
eth1_o_txen <= eth0_io_crs_dv;


-- Outgoing direction: ETH0 -> ETH1
eth0_outgoing_process: process(eth_clk) 
begin
    if rising_edge(eth_clk) then
        OUTGOING_BUFF_0 <= OUTGOING_BUFF_0((1526 * 8) - 4 downto 0) & eth0_io_rxd;
    end if;
end process;


eth1_outgoing_process: process(eth_clk) 
begin
    if rising_edge(eth_clk) then
        eth1_o_txd <= OUTGOING_BUFF_0(1 downto 0);
    end if;
end process;



-- Incomming direction: ETH0 <- ETH1
eth1_incoming_process: process(eth_clk) 
begin
    if rising_edge(eth_clk) then
        INCOMING_BUFF_1 <= INCOMING_BUFF_1((1526 * 8) - 4 downto 0) & eth1_io_rxd;
    end if;
end process;

eth0_incoming_process: process(eth_clk)
variable clk_cycles_behind : integer := 0; -- instantaneous value
variable num_clk_cycles_behind : integer := 0; -- Last max value
variable send_packet : std_logic := '0';
begin
    if rising_edge(eth_clk) then
        
        -- Only increment if recieving packets.
        if eth1_io_crs_dv = '1' then
            clk_cycles_behind := clk_cycles_behind + 1;
        else 
            clk_cycles_behind := 0;
        end if;     
        
        case(incomingState) is 
            when IDLE =>
                
                if classifier_packet_valid = '1' and classifier_forward = '1' then
                    incomingState <= FORWARD;
                    num_clk_cycles_behind := clk_cycles_behind;
                    clk_cycles_behind := 0;
                elsif classifier_packet_valid = '1' and classifier_forward = '0' then
                    num_clk_cycles_behind := 0;
                    incomingState <= DROP;
                end if;
                
            when FORWARD =>
                -- Dont need to change index as the bits get shifted 2 places each clock cycle
                eth0_o_txd <= INCOMING_BUFF_1((num_clk_cycles_behind * 2) - 1 downto (num_clk_cycles_behind * 2) - 2);
                eth0_o_txen <= '1';
                
                num_clk_cycles_behind := num_clk_cycles_behind - 1;
                
                -- Check if all bits have been sent. 
                if num_clk_cycles_behind = 0 then
                    incomingState <= IDLE;
                    eth0_o_txen <= '0';
                end if;
                
            when DROP =>
                -- Ignore the packet incomming
                
                if eth1_io_crs_dv = '0' then
                    incomingState <= IDLE;
                end if;                
        end case;
       
    end if;
end process;


end Behavioral;
