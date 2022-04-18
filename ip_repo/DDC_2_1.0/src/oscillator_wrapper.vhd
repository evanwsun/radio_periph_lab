library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library xil_defaultlib;

entity oscillator_wrapper is
  generic(
    G_OUTPUT_WIDTH : natural := 16;
    G_PHASE_WIDTH : natural := 27
    );
  port(
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_phase : in std_logic_vector(G_PHASE_WIDTH - 1 downto 0);
    i_val : in std_logic;
    o_cos : out std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
    o_sin : out std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
    o_valid : out std_logic
    );
end entity oscillator_wrapper;

architecture oscillator_wrapper of oscillator_wrapper is
  signal osc_data : std_logic_vector(G_OUTPUT_WIDTH * 2 - 1 downto 0);
  signal reset_n : std_logic;
  signal phase_vec : std_logic_vector(32 - 1 downto 0);

  
begin  -- architecture oscillator_wrapper
  
  phase_vec <= ((phase_vec'length - 1 - G_PHASE_WIDTH) downto 0 => '0') & i_phase;
  reset_n <= not i_rst;
  o_sin <= osc_data(osc_data'length - 1 downto G_OUTPUT_WIDTH);
  o_cos <= osc_data(G_OUTPUT_WIDTH - 1 downto 0);
  u_dds : entity xil_defaultlib.oscillator
  PORT MAP (
    aclk => i_clk,
    aresetn => reset_n,
    s_axis_phase_tvalid => i_val,
    s_axis_phase_tdata => phase_vec,
    m_axis_data_tvalid => o_valid,
    m_axis_data_tdata => osc_data,
    m_axis_phase_tvalid => open,
    m_axis_phase_tdata => open
  );

end architecture oscillator_wrapper;
