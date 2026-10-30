----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Testbench  : CPU_TB - self-checking, runs the Appendix B Set 9 program
--
-- Clock period 10 ns. RESET is applied for exactly one rising edge (cycle 0),
-- then the CPU runs one clock cycle per executed instruction (cycles 1..7).
-- After every rising edge ACC (Q), Z and PC (= next PC) are compared with the
-- values printed in Appendix B.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_TB is
end CPU_TB;

architecture Sim of CPU_TB is
    constant T : time := 10 ns;

    signal CLK   : std_logic := '0';
    signal RESET : std_logic := '1';
    signal Q     : std_logic_vector(7 downto 0);
    signal Z     : std_logic;
    signal PC    : std_logic_vector(3 downto 0);
    signal done  : boolean := false;

    -- Expected values from Appendix B (Set 9), index = cycle number 0..7
    type int_arr is array (0 to 7) of integer;
    constant EXP_ACC : int_arr := (16#00#, 16#FF#, 16#00#, 16#00#, 16#11#, 16#22#, 16#22#, 16#44#);
    constant EXP_Z   : int_arr := (1, 0, 1, 1, 0, 0, 0, 0);
    constant EXP_PC  : int_arr := (0, 1, 2, 5, 6, 7, 8, 9);   -- next PC

begin
    ------------------------------------------------------------------ DUT
    DUT : entity work.CPU_TOP
        port map (CLK => CLK, RESET => RESET, Q => Q, Z => Z, PC => PC);

    ------------------------------------------------------------------ clock
    CLK <= not CLK after T / 2 when not done else CLK;

    ------------------------------------------------------------------ stimulus + checker
    process
        variable errors : integer := 0;

        procedure check(cyc : integer) is
            variable acc_i : integer;
            variable z_i   : integer;
            variable pc_i  : integer;
        begin
            acc_i := to_integer(unsigned(Q));
            if Z = '1' then z_i := 1; else z_i := 0; end if;
            pc_i := to_integer(unsigned(PC));

            report "Cycle " & integer'image(cyc) &
                   " | ACC=" & integer'image(acc_i) &
                   " Z=" & integer'image(z_i) &
                   " nextPC=" & integer'image(pc_i) severity note;

            if acc_i /= EXP_ACC(cyc) or z_i /= EXP_Z(cyc) or pc_i /= EXP_PC(cyc) then
                report "MISMATCH at cycle " & integer'image(cyc) &
                       " (expected ACC=" & integer'image(EXP_ACC(cyc)) &
                       " Z=" & integer'image(EXP_Z(cyc)) &
                       " PC=" & integer'image(EXP_PC(cyc)) & ")" severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        -- Cycle 0 : RESET = 1 for one rising edge
        RESET <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        check(0);
        RESET <= '0';

        -- Cycles 1..7 : one clock per executed instruction
        for cyc in 1 to 7 loop
            wait until rising_edge(CLK);
            wait for 1 ns;
            check(cyc);
        end loop;

        if errors = 0 then
            report "TEST PASSED: all 8 cycles match Appendix B (Set 9)." severity note;
        else
            report "TEST FAILED: " & integer'image(errors) & " mismatching cycle(s)." severity error;
        end if;

        wait for T;
        done <= true;
        wait;
    end process;
end Sim;
