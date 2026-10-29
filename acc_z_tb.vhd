----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project | Student ID 22201149 -> Set 9
-- Unit testbench : ACC_Z_TB for ACC_Z (self-checking)
-- Tests: reset values (ACC=0x00, Z=1), write ACC+Z, hold, Z follows D = 0,
--        ACC_WE only, Z_WE only, reset priority over write enables
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ACC_Z_TB is
end ACC_Z_TB;

architecture Sim of ACC_Z_TB is
    constant T : time := 10 ns;
    signal CLK    : std_logic := '0';
    signal RESET  : std_logic := '0';
    signal ACC_WE : std_logic := '0';
    signal Z_WE   : std_logic := '0';
    signal D      : std_logic_vector(7 downto 0) := (others => '0');
    signal ACC    : std_logic_vector(7 downto 0);
    signal Z      : std_logic;
    signal done   : boolean := false;
begin
    DUT : entity work.ACC_Z
        port map (CLK => CLK, RESET => RESET, ACC_WE => ACC_WE, Z_WE => Z_WE, D => D, ACC => ACC, Z => Z);

    CLK <= not CLK after T / 2 when not done else CLK;

    process
        variable errors : integer := 0;

        procedure step(rst, aw, zw : std_logic; d_in : integer; exp_acc : integer; exp_z : std_logic; msg : string) is
        begin
            RESET <= rst; ACC_WE <= aw; Z_WE <= zw; D <= std_logic_vector(to_unsigned(d_in, 8));
            wait until rising_edge(CLK);
            wait for 1 ns;
            if to_integer(unsigned(ACC)) /= exp_acc or Z /= exp_z then
                report "FAIL " & msg & ": ACC=" & integer'image(to_integer(unsigned(ACC))) &
                       " Z=" & std_logic'image(Z) & " expected ACC=" & integer'image(exp_acc) &
                       " Z=" & std_logic'image(exp_z) severity error;
                errors := errors + 1;
            else
                report "ok   " & msg severity note;
            end if;
        end procedure;
    begin
        step('1', '0', '0', 16#00#, 16#00#, '1', "reset: ACC=00 Z=1");
        step('0', '1', '1', 16#FF#, 16#FF#, '0', "write FF (LDI): ACC=FF Z=0");
        step('0', '0', '0', 16#12#, 16#FF#, '0', "no enables: hold");
        step('0', '1', '1', 16#00#, 16#00#, '1', "write 00 (NOT FF): Z=1");
        step('0', '0', '0', 16#34#, 16#00#, '1', "hold (like JZ): ACC and Z unchanged");
        step('0', '1', '1', 16#11#, 16#11#, '0', "write 11 (ADD): Z=0");
        step('0', '1', '0', 16#00#, 16#00#, '0', "ACC_WE only: ACC=00, Z held at 0");
        step('0', '0', '1', 16#80#, 16#00#, '0', "Z_WE only: ACC held, Z from D=80 -> 0");
        step('0', '0', '1', 16#00#, 16#00#, '1', "Z_WE only: D=00 -> Z=1");
        step('0', '1', '1', 16#44#, 16#44#, '0', "write 44");
        step('1', '1', '1', 16#99#, 16#00#, '1', "reset has priority over write enables");

        if errors = 0 then report "ACC_Z_TB: TEST PASSED" severity note;
        else report "ACC_Z_TB: TEST FAILED, errors = " & integer'image(errors) severity error; end if;
        wait for T; done <= true; wait;
    end process;
end Sim;
