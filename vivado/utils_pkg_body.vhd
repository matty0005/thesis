-- utils_pkg_body.vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package body utils_pkg is

  function eth_swap_bits(input_byte: std_logic_vector(7 downto 0)) return std_logic_vector is
    variable reversed_byte: std_logic_vector(7 downto 0);
    begin
      
      reversed_byte(1 downto 0) := input_byte(7 downto 6);
      reversed_byte(3 downto 2) := input_byte(5 downto 4);
      reversed_byte(5 downto 4) := input_byte(3 downto 2);
      reversed_byte(7 downto 6) := input_byte(1 downto 0);

      return reversed_byte;
  end function eth_swap_bits;

end package body utils_pkg;