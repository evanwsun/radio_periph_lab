----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/19/2021 09:03:25 AM
-- Design Name:
-- Module Name: mixer_pkg - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package mixer_pkg is
  constant C_DDS_OUTPUT_WIDTH     : natural := 16;
  constant C_DDS_BOUNDARY_WIDTH   : natural := 16;
  function round_fraction_func (arg : unsigned;
                                len : natural) return unsigned;
  function round_fraction_func (arg : signed;
                                len : natural) return signed;
end package mixer_pkg;

package body mixer_pkg is
  -- round_fraction_func
  function round_fraction_func (arg : unsigned;
                                len : natural) return unsigned is
    constant msb_bit : natural                           := arg'length-1;
    constant rnd_bit : natural                           := (msb_bit-(len-1));
    -- extend for summation
    variable rnd_v   : unsigned(arg'length-1+1 downto 0) := (others => '0');
    variable tmp_v   : unsigned(arg'length-1+1 downto 0) := (others => '0');
  begin
    rnd_v(rnd_bit-1) := '1';
    tmp_v            := arg + rnd_v;
    -- overflow
    if ((arg(msb_bit) = '1') and (tmp_v(msb_bit) = '0')) then
      tmp_v := resize(arg, tmp_v'length);
    end if;
    return tmp_v(msb_bit downto rnd_bit);
  end function round_fraction_func;

  ----------------------------
  -- round_fraction_func
  function round_fraction_func (arg : signed;
                                len : natural) return signed is
  begin
    return signed(round_fraction_func(unsigned(arg), len));
  end function round_fraction_func;


end package body mixer_pkg;
