----------------------------------------------------------------------------------
-- Company: Johns Hopkins Applied Physics Lab
-- Engineer: Evan Sun
--
-- Create Date: 11/03/2021 02:12:58 PM
-- Design Name:
-- Module Name: decimator - Behavioral
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
-- Significant error variance depending on the test frequency put into the
-- FPGA. Unclear as to the ramifications for the entire signal chain
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library xil_defaultlib;

library decimator_lib;
use work.decimator_pkg.all;


entity decimator is
  port (
    ---------------------------------
    -- clk / control
    i_clk     : in  std_logic;
    i_rst     : in  std_logic;
    ---------------------------------
    -- input data
    i_dval    : in  std_logic;
    i_data_re : in  std_logic_vector(C_INPUT_WIDTH -1 downto 0);
    i_data_im : in  std_logic_vector(C_INPUT_WIDTH -1 downto 0);
    ---------------------------------
    -- output data
    o_ready   : out std_logic;
    o_dval    : out std_logic;
    o_data_re : out std_logic_vector(C_OUTPUT_WIDTH -1 downto 0);
    o_data_im : out std_logic_vector(C_OUTPUT_WIDTH -1 downto 0)
    );
end decimator;

architecture rtl of decimator is
  --load_input_proc
  signal dec4_in_data : std_logic_vector(C_INPUT_BOUNDARY_WIDTH*C_NUM_CHAN-1 downto 0);
  signal dec4_dval    : std_logic;
  signal dec4_data    : std_logic_vector(C_INPUT_BOUNDARY_WIDTH*C_NUM_CHAN-1 downto 0);
  --pipe_output_proc
  signal dec2_dval    : std_logic;
  signal dec2_data    : std_logic_vector(C_INPUT_BOUNDARY_WIDTH*C_NUM_CHAN-1 downto 0);
begin
  dec4_in_data <=
    C_ZERO_PAD & i_data_im &
    C_ZERO_PAD & i_data_re;
  ------------------------------------------
  u_dec40_ip : entity xil_defaultlib.lpf_stage1
    port map (
      aclk               => i_clk,
      s_axis_data_tvalid => i_dval,
      s_axis_data_tready => o_ready,
      s_axis_data_tdata  => dec4_in_data,
      m_axis_data_tvalid => dec4_dval,
      m_axis_data_tdata  => dec4_data
      );
  ------------------------------------------
  u_dec64_ip : entity xil_defaultlib.lpf_stage2
    port map (
      aclk               => i_clk,
      s_axis_data_tvalid => dec4_dval,
      s_axis_data_tready => open,
      s_axis_data_tdata  => dec4_data,
      m_axis_data_tvalid => dec2_dval,
      m_axis_data_tdata  => dec2_data
      );
  --Pipes the output from the second stage of decimation to the output
  pipe_output_proc : process (i_clk)
  begin
    if(rising_edge(i_clk)) then
      if(i_rst = '1') then
        o_dval <= '0';
      else
        o_dval    <= dec2_dval;
        o_data_im <= dec2_data(C_OUTPUT_BOUNDARY_WIDTH * 1 + C_OUTPUT_WIDTH -1 downto C_OUTPUT_BOUNDARY_WIDTH * 1);
        o_data_re <= dec2_data(C_OUTPUT_BOUNDARY_WIDTH * 0 + C_OUTPUT_WIDTH -1 downto C_OUTPUT_BOUNDARY_WIDTH * 0);
      end if;
    end if;
  end process pipe_output_proc;
end rtl;
