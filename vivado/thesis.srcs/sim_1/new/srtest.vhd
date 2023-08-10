library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity srlatch_simulation is
end srlatch_simulation;

architecture Behavioral of srlatch_simulation is

    component srlatch is
    Port ( R : in STD_LOGIC;
           S : in STD_LOGIC;
           Q : buffer STD_LOGIC;
           Qn : buffer STD_LOGIC);
    end component;

    signal s, r, Q, Qn : STD_LOGIC;

begin

    -- Unit under test.
    uut : srlatch port map (
        S => s,
        R => r,
        Q => Q,
        Qn => Qn
    );

    generator: process
    begin

       -- Initial zero input.
       s <= '0';
       r <= '0';
        wait for 5ps;
       s <= '1';
       wait for 5ps;

       assert Q = '1' report "Q not high when latch set" severity error;
       assert Qn = '0' report "Qn not low when latch set" severity error;

       s <= '0';
       wait for 5ps;
       assert Q = '1' report "Q not high when latch released after set" severity error;
       assert Qn = '0' report "Qn not low when latch released after set" severity error;

       r <= '1';
       wait for 5ps;
       assert Q = '0' report "Q not low when latch reset" severity error;
       assert Qn = '1' report "Qn not high when latch reset" severity error;

       r <= '0';
       wait for 5ps;
       assert Q = '0' report "Q not low when latch released after reset" severity error;
       assert Qn = '1' report "Qn not high when latch released after reset" severity error;

       wait;
    end process;

end Behavioral;