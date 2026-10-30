----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : CPU_TOP - Mini 8-bit single-cycle accumulator CPU
--
-- Ports : CLK, RESET (sync, active-high), Q[7:0] (= ACC), Z flag, PC[3:0]
-- Blocks: PC -> Program_ROM -> Control_Unit -> ALU -> ACC_Z
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU_TOP is
    port (
        CLK   : in  std_logic;
        RESET : in  std_logic;
        Q     : out std_logic_vector(7 downto 0);   -- accumulator
        Z     : out std_logic;                      -- zero flag
        PC    : out std_logic_vector(3 downto 0)    -- program counter (for checking)
    );
end CPU_TOP;

architecture Structural of CPU_TOP is
    signal pc_s      : std_logic_vector(3 downto 0);
    signal instr_s   : std_logic_vector(11 downto 0);
    signal opcode_s  : std_logic_vector(3 downto 0);
    signal operand_s : std_logic_vector(7 downto 0);
    signal alu_sel_s : std_logic_vector(1 downto 0);
    signal acc_we_s  : std_logic;
    signal z_we_s    : std_logic;
    signal pc_load_s : std_logic;
    signal alu_res_s : std_logic_vector(7 downto 0);
    signal acc_s     : std_logic_vector(7 downto 0);
    signal z_s       : std_logic;
begin
    opcode_s  <= instr_s(11 downto 8);
    operand_s <= instr_s(7 downto 0);

    U_PC : entity work.Program_Counter
        port map (CLK => CLK, RESET => RESET, LOAD => pc_load_s,
                  LOAD_ADDR => operand_s(3 downto 0), PC_OUT => pc_s);

    U_ROM : entity work.Program_ROM
        port map (ADDR => pc_s, INSTR => instr_s);

    U_CU : entity work.Control_Unit
        port map (OPCODE => opcode_s, Z => z_s, ALU_SEL => alu_sel_s,
                  ACC_WE => acc_we_s, Z_WE => z_we_s, PC_LOAD => pc_load_s);

    U_ALU : entity work.ALU
        port map (ACC => acc_s, OPERAND => operand_s, SEL => alu_sel_s,
                  RESULT => alu_res_s);

    U_ACCZ : entity work.ACC_Z
        port map (CLK => CLK, RESET => RESET, ACC_WE => acc_we_s, Z_WE => z_we_s,
                  D => alu_res_s, ACC => acc_s, Z => z_s);

    Q  <= acc_s;
    Z  <= z_s;
    PC <= pc_s;
end Structural;
