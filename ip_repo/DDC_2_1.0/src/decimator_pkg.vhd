----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2021 09:03:25 AM
-- Design Name: 
-- Module Name: decimator_pkg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package decimator_pkg is
  constant C_NUM_CHAN : integer := 2;
  constant C_INPUT_WIDTH : integer := 16;
  constant C_OUTPUT_WIDTH : integer := 16;
  --Decimator generator sign extends the output to the nearest 8 bit boundary
  constant C_INPUT_BOUNDARY_WIDTH  : natural                                                              := 16;
  constant C_OUTPUT_BOUNDARY_WIDTH : natural                                                              := 16;
  --0 pads the decimator generator input length to the nearest 8 bit boundary e.g 18 => 24
  constant C_ZERO_PAD              : std_logic_vector(C_INPUT_BOUNDARY_WIDTH - C_INPUT_WIDTH -1 downto 0) := (others => '0');
end package decimator_pkg;

package body decimator_pkg is
  
  
end package body decimator_pkg;
