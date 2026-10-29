----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : Control Unit (combinational decoder of opcode instr[11:8])
--
-- Opcode  Instr  ALU_SEL  ACC_WE  Z_WE  PC_LOAD
-- 0001    LDI    00       1       1     0
-- 0010    ADD    01       1       1     0
-- 0111    NOT    10       1       1     0
-- 1000    SHL    11       1       1     0
-- 1100    JZ     --       0       0     Z      (PC <- operand[3:0] if Z = 1)
-- others  NOP    --       0       0     0      (0000 and every opcode not in Set 9)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit is
    port (
        OPCODE  : in  std_logic_vector(3 downto 0);
        Z       : in  std_logic;                       -- current Z flag (for JZ)
        ALU_SEL : out std_logic_vector(1 downto 0);
        ACC_WE  : out std_logic;
        Z_WE    : out std_logic;
        PC_LOAD : out std_logic
    );
end Control_Unit;

architecture Behavioral of Control_Unit is
begin
    process (OPCODE, Z)
    begin
        -- defaults = NOP
        ALU_SEL <= "00";
        ACC_WE  <= '0';
        Z_WE    <= '0';
        PC_LOAD <= '0';

        case OPCODE is
            when "0001" =>                     -- LDI
                ALU_SEL <= "00"; ACC_WE <= '1'; Z_WE <= '1';
            when "0010" =>                     -- ADD
                ALU_SEL <= "01"; ACC_WE <= '1'; Z_WE <= '1';
            when "0111" =>                     -- NOT
                ALU_SEL <= "10"; ACC_WE <= '1'; Z_WE <= '1';
            when "1000" =>                     -- SHL
                ALU_SEL <= "11"; ACC_WE <= '1'; Z_WE <= '1';
            when "1100" =>                     -- JZ
                if Z = '1' then
                    PC_LOAD <= '1';
                end if;
            when others =>                     -- NOP
                null;
        end case;
    end process;
end Behavioral;
