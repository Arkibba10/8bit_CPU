----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : Program ROM (16 x 12 bit), combinational read using PC
--
-- Appendix B, Set 9 program        instr = opcode(4) & operand(8)
--   0: LDI 0xFF  -> 0x1FF
--   1: NOT       -> 0x700
--   2: JZ  0x05  -> 0xC05
--   3: ADD 0x77  -> 0x277
--   4: ADD 0x77  -> 0x277
--   5: ADD 0x11  -> 0x211
--   6: SHL       -> 0x800
--   7: JZ  0x00  -> 0xC00
--   8: SHL       -> 0x800
--   9..15: 0x000 (NOP)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Program_ROM is
    port (
        ADDR  : in  std_logic_vector(3 downto 0);
        INSTR : out std_logic_vector(11 downto 0)
    );
end Program_ROM;

architecture Behavioral of Program_ROM is
    type rom_t is array (0 to 15) of std_logic_vector(11 downto 0);
    constant ROM : rom_t := (
        0      => x"1FF",   -- LDI 0xFF
        1      => x"700",   -- NOT
        2      => x"C05",   -- JZ  0x05
        3      => x"277",   -- ADD 0x77
        4      => x"277",   -- ADD 0x77
        5      => x"211",   -- ADD 0x11
        6      => x"800",   -- SHL
        7      => x"C00",   -- JZ  0x00
        8      => x"800",   -- SHL
        others => x"000"    -- NOP
    );
begin
    INSTR <= ROM(to_integer(unsigned(ADDR)));
end Behavioral;
