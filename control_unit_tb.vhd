----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project | Student ID 22201149 -> Set 9
-- Unit testbench : CONTROL_UNIT_TB for Control_Unit (self-checking)
-- Tests: all 16 opcodes x Z = 0/1.
--   LDI/ADD/NOT/SHL : ACC_WE = Z_WE = 1, ALU_SEL = 00/01/10/11, PC_LOAD = 0
--   JZ              : PC_LOAD = Z, ACC_WE = Z_WE = 0
--   every other opcode (incl. 0000) = NOP : all enables 0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CONTROL_UNIT_TB is
end CONTROL_UNIT_TB;

architecture Sim of CONTROL_UNIT_TB is
    signal OPCODE  : std_logic_vector(3 downto 0) := (others => '0');
    signal Z       : std_logic := '0';
    signal ALU_SEL : std_logic_vector(1 downto 0);
    signal ACC_WE, Z_WE, PC_LOAD : std_logic;
begin
    DUT : entity work.Control_Unit
        port map (OPCODE => OPCODE, Z => Z, ALU_SEL => ALU_SEL,
                  ACC_WE => ACC_WE, Z_WE => Z_WE, PC_LOAD => PC_LOAD);

    process
        variable errors : integer := 0;
        variable exp_we, exp_pc : std_logic;
        variable exp_sel : std_logic_vector(1 downto 0);
        variable check_sel : boolean;
    begin
        for op in 0 to 15 loop
            for zv in 0 to 1 loop
                OPCODE <= std_logic_vector(to_unsigned(op, 4));
                if zv = 1 then Z <= '1'; else Z <= '0'; end if;
                wait for 10 ns;

                exp_we := '0'; exp_pc := '0'; exp_sel := "00"; check_sel := false;
                case op is
                    when 1  => exp_we := '1'; exp_sel := "00"; check_sel := true;   -- LDI
                    when 2  => exp_we := '1'; exp_sel := "01"; check_sel := true;   -- ADD
                    when 7  => exp_we := '1'; exp_sel := "10"; check_sel := true;   -- NOT
                    when 8  => exp_we := '1'; exp_sel := "11"; check_sel := true;   -- SHL
                    when 12 => if zv = 1 then exp_pc := '1'; end if;                -- JZ
                    when others => null;                                            -- NOP
                end case;

                if ACC_WE /= exp_we or Z_WE /= exp_we or PC_LOAD /= exp_pc or
                   (check_sel and ALU_SEL /= exp_sel) then
                    report "FAIL opcode=" & integer'image(op) & " Z=" & integer'image(zv) &
                           " got ACC_WE=" & std_logic'image(ACC_WE) & " Z_WE=" & std_logic'image(Z_WE) &
                           " PC_LOAD=" & std_logic'image(PC_LOAD) severity error;
                    errors := errors + 1;
                else
                    report "ok   opcode=" & integer'image(op) & " Z=" & integer'image(zv) severity note;
                end if;
            end loop;
        end loop;

        if errors = 0 then report "CONTROL_UNIT_TB: TEST PASSED" severity note;
        else report "CONTROL_UNIT_TB: TEST FAILED, errors = " & integer'image(errors) severity error; end if;
        wait;
    end process;
end Sim;
