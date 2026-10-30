----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project | Student ID 22201149 -> Set 9
-- Unit testbench : PC_TB for Program_Counter (self-checking)
-- Tests: reset, count up, load (JZ taken), count after load, wrap 15 -> 0, reset priority
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_TB is
end PC_TB;

architecture Sim of PC_TB is
    constant T : time := 10 ns;
    signal CLK       : std_logic := '0';
    signal RESET     : std_logic := '0';
    signal LOAD      : std_logic := '0';
    signal LOAD_ADDR : std_logic_vector(3 downto 0) := (others => '0');
    signal PC_OUT    : std_logic_vector(3 downto 0);
    signal done      : boolean := false;
begin
    DUT : entity work.Program_Counter
        port map (CLK => CLK, RESET => RESET, LOAD => LOAD, LOAD_ADDR => LOAD_ADDR, PC_OUT => PC_OUT);

    CLK <= not CLK after T / 2 when not done else CLK;

    process
        variable errors : integer := 0;

        -- one clock cycle with the given inputs, then check PC_OUT
        procedure step(rst, ld : std_logic; addr : integer; expected : integer; msg : string) is
        begin
            RESET <= rst; LOAD <= ld; LOAD_ADDR <= std_logic_vector(to_unsigned(addr, 4));
            wait until rising_edge(CLK);
            wait for 1 ns;
            if to_integer(unsigned(PC_OUT)) /= expected then
                report "FAIL " & msg & ": PC=" & integer'image(to_integer(unsigned(PC_OUT))) &
                       " expected " & integer'image(expected) severity error;
                errors := errors + 1;
            else
                report "ok   " & msg & ": PC=" & integer'image(expected) severity note;
            end if;
        end procedure;
    begin
        step('1', '0', 0, 0,  "reset");
        step('0', '0', 0, 1,  "count 1");
        step('0', '0', 0, 2,  "count 2");
        step('0', '0', 0, 3,  "count 3");
        step('0', '1', 5, 5,  "load 5 (JZ taken)");
        step('0', '0', 0, 6,  "count after load");
        step('0', '1', 15, 15, "load 15");
        step('0', '0', 0, 0,  "wrap 15 -> 0");
        step('0', '1', 9, 9,  "load 9");
        step('1', '1', 7, 0,  "reset has priority over load");
        step('0', '0', 0, 1,  "count after reset");
        step('0', '1', 0, 0,  "load 0 (JZ 0x00)");

        if errors = 0 then report "PC_TB: TEST PASSED" severity note;
        else report "PC_TB: TEST FAILED, errors = " & integer'image(errors) severity error; end if;
        wait for T; done <= true; wait;
    end process;
end Sim;
