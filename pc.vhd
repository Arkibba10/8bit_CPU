----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : Program_Counter  (4-bit PC)
-- Function   : Synchronous, active-high RESET (PC <- 0).
--              LOAD = '1' (JZ taken)  -> PC <- LOAD_ADDR
--              LOAD = '0'             -> PC <- PC + 1  (wraps 15 -> 0)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Program_Counter is
    port (
        CLK       : in  std_logic;
        RESET     : in  std_logic;
        LOAD      : in  std_logic;                      -- '1' when JZ is taken
        LOAD_ADDR : in  std_logic_vector(3 downto 0);   -- operand[3:0]
        PC_OUT    : out std_logic_vector(3 downto 0) := (others => '0')
    );
end Program_Counter;

architecture Behavioral of Program_Counter is
    signal pc_reg : unsigned(3 downto 0) := (others => '0');
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                pc_reg <= (others => '0');
            elsif LOAD = '1' then
                pc_reg <= unsigned(LOAD_ADDR);
            else
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

    PC_OUT <= std_logic_vector(pc_reg);
end Behavioral;
