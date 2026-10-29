----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project | Student ID 22201149 -> Set 9
-- Unit testbench : ALU_TB for ALU (self-checking)
-- SEL 00 LDI = OPERAND | 01 ADD = ACC+OPERAND (mod 256) | 10 NOT = not ACC | 11 SHL = ACC<<1
-- Tests: directed corner cases + loops over many ACC / OPERAND values for every operation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_TB is
end ALU_TB;

architecture Sim of ALU_TB is
    signal ACC, OPERAND, RESULT : std_logic_vector(7 downto 0) := (others => '0');
    signal SEL : std_logic_vector(1 downto 0) := "00";
begin
    DUT : entity work.ALU port map (ACC => ACC, OPERAND => OPERAND, SEL => SEL, RESULT => RESULT);

    process
        variable errors, checks : integer := 0;

        procedure check(a, b, s, expected : integer; name : string) is
        begin
            ACC <= std_logic_vector(to_unsigned(a, 8));
            OPERAND <= std_logic_vector(to_unsigned(b, 8));
            SEL <= std_logic_vector(to_unsigned(s, 2));
            wait for 5 ns;
            checks := checks + 1;
            if to_integer(unsigned(RESULT)) /= expected then
                report "FAIL " & name & " ACC=" & integer'image(a) & " OP=" & integer'image(b) &
                       ": got " & integer'image(to_integer(unsigned(RESULT))) &
                       " expected " & integer'image(expected) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        -- directed cases (Set 9 program values and corner cases)
        check(16#00#, 16#FF#, 0, 16#FF#, "LDI");
        check(16#AA#, 16#00#, 0, 16#00#, "LDI zero");
        check(16#00#, 16#11#, 1, 16#11#, "ADD");
        check(16#FF#, 16#01#, 1, 16#00#, "ADD wrap");
        check(16#77#, 16#77#, 1, 16#EE#, "ADD 0x77+0x77");
        check(16#FF#, 16#00#, 2, 16#00#, "NOT 0xFF");
        check(16#00#, 16#00#, 2, 16#FF#, "NOT 0x00");
        check(16#55#, 16#FF#, 2, 16#AA#, "NOT ignores operand");
        check(16#11#, 16#FF#, 3, 16#22#, "SHL 0x11 (operand ignored)");
        check(16#80#, 16#00#, 3, 16#00#, "SHL 0x80 -> 0 (MSB lost)");
        check(16#FF#, 16#00#, 3, 16#FE#, "SHL 0xFF");
        check(16#01#, 16#00#, 3, 16#02#, "SHL 0x01");

        -- sweeps
        for a in 0 to 255 loop
            check(a, 16#5A#, 2, 255 - a,           "NOT sweep");
            check(a, 16#A5#, 3, (a * 2) mod 256,   "SHL sweep");
            for b in 0 to 255 loop
                if (a + b) mod 7 = 0 then   -- ~1/7 of all 65536 pairs, plenty of coverage
                    check(a, b, 1, (a + b) mod 256, "ADD sweep");
                    check(a, b, 0, b,               "LDI sweep");
                end if;
            end loop;
        end loop;

        report "ALU_TB: " & integer'image(checks) & " checks done";
        if errors = 0 then report "ALU_TB: TEST PASSED" severity note;
        else report "ALU_TB: TEST FAILED, errors = " & integer'image(errors) severity error; end if;
        wait;
    end process;
end Sim;
