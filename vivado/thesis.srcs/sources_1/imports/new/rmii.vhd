--------------------------------------------------------------------------------
-- RMII interface between 8bits to 2bit RMII 
-- Uses FIFOs
--
-- IO DESCRIPTION
--           
--
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_ARITH.all;
use ieee.STD_LOGIC_UNSIGNED.all;


entity rmii is
  Port (
    rmii_i_rst      : in std_logic;
    -- From ethernet MAC
    rmii_i_tx_ready : in std_logic;
    rmii_i_tx_dat   : in std_logic_vector(7 downto 0);
    rmii_i_tx_start   : in std_logic;
    
    rmii_o_txd      : out std_logic_vector(1 downto 0) := "00";
    rmii_o_txen     : out std_logic; 
    clk_i_write : in STD_LOGIC;
    clk_i_read : in STD_LOGIC;
    
    eth_i_rxderr    : out std_logic
  );
end rmii;



architecture Behavioral of rmii is

    constant FIFO_DEPTH : integer := 1600; -- Can then use 11 bits
    type fifo_mem is array (FIFO_DEPTH downto 0) of STD_LOGIC_VECTOR (7 downto 0);
    signal fifo : fifo_mem;
    signal read_ptr, write_ptr : integer := 0;
    signal fifo_full, fifo_empty : boolean := false;
    signal current_read_byte : STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal bit_idx : natural range 0 to 7 := 0;
    
    signal txen : std_logic := '0';
    signal txd : std_logic_vector(1 downto 0) := "00";
    
    
--    signal write_ptr_next : integer := 0;
--    signal fifo_full_next : boolean := false;
        
begin
    
    process(clk_i_write, rmii_i_rst)
    begin
        if rmii_i_rst = '0' then -- active low
            write_ptr <= 0;
        elsif rising_edge(clk_i_write) then
            -- Write to FIFO
            if rmii_i_tx_ready = '1' and not fifo_full then
                fifo(write_ptr) <= rmii_i_tx_dat;
            end if;

            -- Increment write pointer
            if write_ptr = FIFO_DEPTH then
                write_ptr <= 0;
            elsif rmii_i_tx_ready = '1' and not fifo_full then
                write_ptr <= write_ptr + 1;
            end if;

        end if;
    end process;
    
    -- Update fifo status
    process(clk_i_write, rmii_i_rst)
    begin
        if rmii_i_rst = '0' then -- active low
            fifo_full <= false;
        elsif rising_edge(clk_i_write) then
            -- Update FIFO full status
            if (write_ptr + 1) = FIFO_DEPTH then
                fifo_full <= read_ptr = 0;
            else
                fifo_full <= (write_ptr + 1) = read_ptr;
            end if;
            
            
        end if;
    end process;
    
    
    
    
    TX_OUT: process(clk_i_read, rmii_i_rst)
    begin
        if rmii_i_rst = '0' then
            read_ptr <= 0;
            bit_idx <= 0;
            txen <= '0';
            current_read_byte <= (others => '0');
        elsif rising_edge(clk_i_read) then
            -- Read from FIFO
            -- Update FIFO empty status
--            fifo_empty <= write_ptr = read_ptr;
            if write_ptr = read_ptr + 1 and bit_idx = 6 then 
                fifo_empty <= true;
            else 
                fifo_empty <= write_ptr = read_ptr;
            end if;
            
            
            if write_ptr /= read_ptr then
                txen <= '1';
                if bit_idx = 0 then
                    current_read_byte <= fifo(read_ptr);
                    txd <=  fifo(read_ptr)(1 downto 0);
                else
                    txd <= current_read_byte((bit_idx + 1) downto bit_idx);
                end if;
                
                if bit_idx = 6 then
                    read_ptr <= (read_ptr + 1) mod FIFO_DEPTH;
                end if;
                                
                bit_idx <= (bit_idx + 2) mod 8;
               
            else 
                txd <= "00";
                txen <= '0';
            end if;

            
        end if;
    end process;
    
    rmii_o_txd <= txd;
    rmii_o_txen <= '1' when (not fifo_empty) else '0'; --data out valid
end Behavioral;


