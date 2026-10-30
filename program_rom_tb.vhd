----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project | Student ID 22201149 -> Set 9
-- Unit testbench : PROGRAM_ROM_TB for Program_ROM (self-checking)
-- Tests: every address 0..15 against the Appendix B Set 9 program (unused = 0x000)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PROGRAM_ROM_TB is
end PROGRAM_ROM_TB;

architecture Sim of PROGRAM_ROM_TB is
    signal ADDR  : std_logic_vector(3 downto 0) := (others => '0');
    signal INSTR : std_logic_vector(11 downto 0);

    type rom_t is array (0 to 15) of integer;
    constant EXPECTED : rom_t := (
        16#1FF#,  -- 0: LDI 0xFF
        16#700#,  -- 1: NOT
        16#C05#,  -- 2: JZ  0x05
        16#277#,  -- 3: ADD 0x77
        16#277#,  -- 4: ADD 0x77
        16#211#,  -- 5: ADD 0x11
        16#800#,  -- 6: SHL
        16#C00#,  -- 7: JZ  0x00
        16#800#,  -- 8: SHL
        16#000#, 16#000#, 16#000#, 16#000#, 16#000#, 16#000#, 16#000#);  -- 9..15: NOP
begin
    DUT : entity work.Program_ROM port map (ADDR => ADDR, INSTR => INSTR);

    process
        variable errors : integer := 0;
    begin
        for a in 0 to 15 loop
            ADDR <= std_logic_vector(to_unsigned(a, 4));
            wait for 10 ns;
            if to_integer(unsigned(INSTR)) /= EXPECTED(a) then
                report "FAIL addr " & integer'image(a) & ": INSTR=" &
                       integer'image(to_integer(unsigned(INSTR))) & " expected " &
                       integer'image(EXPECTED(a)) severity error;
                errors := errors + 1;
            else
                report "ok   addr " & integer'image(a) & ": INSTR=" &
                       integer'image(EXPECTED(a)) severity note;
            end if;
        end loop;

        if errors = 0 then report "PROGRAM_ROM_TB: TEST PASSED" severity note;
        else report "PROGRAM_ROM_TB: TEST FAILED, errors = " & integer'image(errors) severity error; end if;
        wait;
    end process;
end Sim;
