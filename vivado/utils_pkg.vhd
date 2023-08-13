-- utils_pkg.vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package utils_pkg is
  function eth_swap_bits(input_byte: std_logic_vector(7 downto 0)) return std_logic_vector;
end package utils_pkg;
