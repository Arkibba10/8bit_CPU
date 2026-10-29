----------------------------------------------------------------------------------
-- CSE 450 (VLSI Lab) - Final Project, Spring 2026
-- Student ID : 22201149  ->  Set 9  (LDI, ADD, NOT, SHL, JZ)
-- Module     : ACC and Z flag registers
--              (Set 9 has no STA / LDR, so the holding register R is not needed)
--
-- RESET = '1' at rising edge : ACC <- 0x00, Z <- 1   (priority over everything)
-- ACC_WE = '1'               : ACC <- D
-- Z_WE   = '1'               : Z   <- 1 if D = 0x00, else 0
-- otherwise registers keep their values.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ACC_Z is
    port (
        CLK    : in  std_logic;
        RESET  : in  std_logic;
        ACC_WE : in  std_logic;
        Z_WE   : in  std_logic;
        D      : in  std_logic_vector(7 downto 0);   -- ALU result
        ACC    : out std_logic_vector(7 downto 0);
        Z      : out std_logic
    );
end ACC_Z;

architecture Behavioral of ACC_Z is
    signal acc_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal z_reg   : std_logic := '1';
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                acc_reg <= (others => '0');
                z_reg   <= '1';
            else
                if ACC_WE = '1' then
                    acc_reg <= D;
                end if;
                if Z_WE = '1' then
                    if D = "00000000" then
                        z_reg <= '1';
                    else
                        z_reg <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    ACC <= acc_reg;
    Z   <= z_reg;
end Behavioral;
