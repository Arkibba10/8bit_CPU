----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : ALU (8-bit, combinational)
--
-- SEL  Operation   Result
-- 00   LDI         OPERAND
-- 01   ADD         ACC + OPERAND   (8-bit, carry discarded)
-- 10   NOT         NOT ACC         (operand ignored)
-- 11   SHL         ACC << 1        (0 enters LSB, operand ignored)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
        ACC     : in  std_logic_vector(7 downto 0);
        OPERAND : in  std_logic_vector(7 downto 0);
        SEL     : in  std_logic_vector(1 downto 0);
        RESULT  : out std_logic_vector(7 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
begin
    process (ACC, OPERAND, SEL)
    begin
        case SEL is
            when "00"   => RESULT <= OPERAND;
            when "01"   => RESULT <= std_logic_vector(unsigned(ACC) + unsigned(OPERAND));
            when "10"   => RESULT <= not ACC;
            when others => RESULT <= ACC(6 downto 0) & '0';
        end case;
    end process;
end Behavioral;
