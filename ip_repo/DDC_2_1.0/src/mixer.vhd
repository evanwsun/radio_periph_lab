----------------------------------------------------------------------------------
-- Company: Johns Hopkins Applied Physics Lab
-- Engineer: Evan Sun
--
-- Create Date: 11/03/2021 02:12:58 PM
-- Design Name:
-- Module Name: mixer - Behavioral
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
----------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;


use work.mixer_pkg.all;

entity mixer is
  generic(
    G_INPUT_WIDTH  : natural := 16;
    G_OUTPUT_WIDTH : natural := 16;
    G_PHASE_WIDTH  : natural := 27
    );
  port(
    ---------------------------------
    -- clk / control
    i_clk        : in  std_logic;
    i_rst        : in  std_logic;
    --
    i_phase      : in  std_logic_vector(G_PHASE_WIDTH - 1 downto 0);
    i_phase_dval : in  std_logic;
    --------------------------------
    -- input data
    i_dval       : in  std_logic;
    i_data       : in  std_logic_vector(G_INPUT_WIDTH -1 downto 0);
    ---------------------------------
    -- output data
    o_dval       : out std_logic;
    o_data_re    : out std_logic_vector(G_OUTPUT_WIDTH -1 downto 0);
    o_data_im    : out std_logic_vector(G_OUTPUT_WIDTH -1 downto 0);
    o_ready      : out std_logic
    );

end mixer;
architecture rtl of mixer is
  signal cosine : std_logic_vector(C_DDS_OUTPUT_WIDTH -1 downto 0) := (others => '0');
  signal sine   : std_logic_vector(C_DDS_OUTPUT_WIDTH -1 downto 0) := (others => '0');
begin
  u_mixer_osc : entity work.oscillator_wrapper
    port map (
      i_clk   => i_clk,
      i_rst   => i_rst,
      i_phase => i_phase,
      i_val   => i_phase_dval,
      o_cos   => cosine,
      o_sin   => sine,
      o_valid => open
      );
  mix_input_proc : process (i_clk, i_rst)
    variable data_re_v : std_logic_vector(C_DDS_OUTPUT_WIDTH + G_INPUT_WIDTH - 1 downto 0);
    variable data_im_v : std_logic_vector(C_DDS_OUTPUT_WIDTH + G_INPUT_WIDTH - 1 downto 0);
  begin
    if(rising_edge(i_clk)) then
      if(i_rst = '1') then
        o_dval <= '0';
      else
        o_dval    <= i_dval;
        data_re_v := std_logic_vector(signed(cosine) * signed(i_data));
        data_im_v := std_logic_vector(signed(sine) * signed(i_data));
        o_data_re <= data_re_v(data_re_v'length - 1 downto data_re_v'length - G_OUTPUT_WIDTH);
        o_data_im <= data_im_v(data_im_v'length - 1 downto data_im_v'length - G_OUTPUT_WIDTH);
      end if;
    end if;
  end process;
end rtl;
