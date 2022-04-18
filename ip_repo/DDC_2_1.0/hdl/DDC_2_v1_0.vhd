library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DDC_2_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface config
		C_config_DATA_WIDTH	: integer	:= 32;
		C_config_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        o_tvalid : out std_logic;
        o_tdata : out std_logic_vector(31 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface config
		config_aclk	: in std_logic;
		config_aresetn	: in std_logic;
		config_awaddr	: in std_logic_vector(C_config_ADDR_WIDTH-1 downto 0);
		config_awprot	: in std_logic_vector(2 downto 0);
		config_awvalid	: in std_logic;
		config_awready	: out std_logic;
		config_wdata	: in std_logic_vector(C_config_DATA_WIDTH-1 downto 0);
		config_wstrb	: in std_logic_vector((C_config_DATA_WIDTH/8)-1 downto 0);
		config_wvalid	: in std_logic;
		config_wready	: out std_logic;
		config_bresp	: out std_logic_vector(1 downto 0);
		config_bvalid	: out std_logic;
		config_bready	: in std_logic;
		config_araddr	: in std_logic_vector(C_config_ADDR_WIDTH-1 downto 0);
		config_arprot	: in std_logic_vector(2 downto 0);
		config_arvalid	: in std_logic;
		config_arready	: out std_logic;
		config_rdata	: out std_logic_vector(C_config_DATA_WIDTH-1 downto 0);
		config_rresp	: out std_logic_vector(1 downto 0);
		config_rvalid	: out std_logic;
		config_rready	: in std_logic
	);
end DDC_2_v1_0;

architecture arch_imp of DDC_2_v1_0 is

	-- component declaration
	component DDC_2_v1_0_config is
		generic (
        G_PHASE_WIDTH : natural := 27;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
				-- Users to add ports here
        o_dds_phase : out std_logic_vector(G_PHASE_WIDTH - 1 downto 0);
        o_mixer_phase : out std_logic_vector(G_PHASE_WIDTH - 1 downto 0);
        o_rst : out std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component DDC_2_v1_0_config;

	constant C_PHASE_WIDTH : natural := 27;
	constant G_OUTPUT_WIDTH : natural := 16;
	signal rst : std_logic;
	    --user signals 
      signal sys_clk                                  : std_logic;
    signal sys_rst : std_logic;
      ------------------------------------------------------------------------------
  --Mixer
  signal mixer_phase                              : std_logic_vector(C_PHASE_WIDTH - 1 downto 0);
  signal phase_re                                 : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  signal phase_im                                 : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  signal phase_dval                               : std_logic;
  ------------------------------------------------------------------------------
  --DDS
  signal dds_phase                                : std_logic_vector(C_PHASE_WIDTH - 1 downto 0);
  signal dds_val                                  : std_logic;
  signal dds_cos                                  : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  signal dds_sin                                  : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  signal dds_valid                                : std_logic;
  ------------------------------------------------------------------------------
  --Decimator
  signal dec_re                                   : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  signal dec_im                                   : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0);
  ------------------------------------------------------------------------------
  --FIFO intf
  signal audio_data                               : std_logic_vector(31 downto 0);
    
begin

-- Instantiation of Axi Bus Interface config
DDC_2_v1_0_config_inst : DDC_2_v1_0_config
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_config_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_config_ADDR_WIDTH
	)
	port map (
        o_dds_phase => dds_phase,
        o_mixer_phase => mixer_phase,
        o_rst => rst,
		S_AXI_ACLK	=> config_aclk,
		S_AXI_ARESETN	=> config_aresetn,
		S_AXI_AWADDR	=> config_awaddr,
		S_AXI_AWPROT	=> config_awprot,
		S_AXI_AWVALID	=> config_awvalid,
		S_AXI_AWREADY	=> config_awready,
		S_AXI_WDATA	=> config_wdata,
		S_AXI_WSTRB	=> config_wstrb,
		S_AXI_WVALID	=> config_wvalid,
		S_AXI_WREADY	=> config_wready,
		S_AXI_BRESP	=> config_bresp,
		S_AXI_BVALID	=> config_bvalid,
		S_AXI_BREADY	=> config_bready,
		S_AXI_ARADDR	=> config_araddr,
		S_AXI_ARPROT	=> config_arprot,
		S_AXI_ARVALID	=> config_arvalid,
		S_AXI_ARREADY	=> config_arready,
		S_AXI_RDATA	=> config_rdata,
		S_AXI_RRESP	=> config_rresp,
		S_AXI_RVALID	=> config_rvalid,
		S_AXI_RREADY	=> config_rready
	);

	-- Add user logic here
	sys_rst <= rst or not config_aresetn;
	sys_clk <= config_aclk;
	o_tdata <= audio_data;
	audio_data <= std_logic_vector(shift_left(signed(dec_re), 3)) & std_logic_vector(shift_left(signed(dec_im), 3));
      
  u_test_src : entity work.oscillator_wrapper
    port map (
      i_clk   => sys_clk,
      i_rst   => sys_rst,
      i_phase => dds_phase,
      i_val   => '1',
      o_cos   => dds_cos,
      o_sin   => dds_sin,
      o_valid => dds_valid
      );

  
  mixer_1 : entity work.mixer
    generic map (
      G_INPUT_WIDTH  => G_OUTPUT_WIDTH,
      G_OUTPUT_WIDTH => G_OUTPUT_WIDTH,
      G_PHASE_WIDTH  => C_PHASE_WIDTH
      )
    port map (
      ---------------------------------
      -- clk / control
      i_clk        => sys_clk,
      i_rst        => sys_rst,
      --
      i_phase      => mixer_phase,
      i_phase_dval => '1',
      --------------------------------
      -- input data
      i_dval       => '1',
      i_data       => dds_cos,
      ---------------------------------
      -- output data
      o_dval       => phase_dval,
      o_data_re    => phase_re,
      o_data_im    => phase_im,
      o_ready      => open
      );

  decimator_1 : entity work.decimator
    port map (
      ---------------------------------
      -- clk / control
      i_clk     => sys_clk,
      i_rst     => sys_rst,
      ---------------------------------
      -- input data
      i_dval    => phase_dval,
      i_data_re => phase_re,
      i_data_im => phase_im,
      ---------------------------------
      -- output data
      o_ready   => open,
      o_dval    => o_tvalid,
      o_data_re => dec_re,
      o_data_im => dec_im
      );

	-- User logic ends

end arch_imp;
