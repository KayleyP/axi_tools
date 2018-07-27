--********************************************************************************************************************--
--! @file
--! @brief File Description
--! Copyright&copy - YOUR COMPANY NAME
--********************************************************************************************************************--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Local libraries
library work;

--! Entity/Package Description
entity aes3_tb is
end entity aes3_tb;

architecture behav of aes3_tb is

  signal   s_clk      : std_logic;
  signal   rst        : std_logic;
  signal   udata_l    : std_logic_vector(191 downto 0) := (others => '0');
  signal   udata_r    : std_logic_vector(191 downto 0) := (others => '0');
  signal   cdata_l    : std_logic_vector(191 downto 0) := (others => '0');
  signal   cdata_r    : std_logic_vector(191 downto 0) := (others => '0');
  signal   sample     : std_logic_vector(23 downto 0) := (others => '0');
  signal   master_aes_data    : std_logic;
  signal   slave_aes_data     : std_logic;
  signal   new_sample : std_logic;
  signal   new_block  : std_logic;
  signal   clk_50m    : std_logic;

  
  signal stop_clk : boolean := false;
  constant S_CLK_PERIOD : time := 333 ns;
  constant CLK_50M_PERIOD : time := 20 ns;

begin
   comp_aes3_tx : entity work.aes3_tx
    port map (
      s_clk      => s_clk,
      rst        => rst,
      udata_l    => udata_l,
      udata_r    => udata_r,
      cdata_l    => cdata_l,
      cdata_r    => cdata_r,
      sample     => sample,
      aes_data   => master_aes_data,
      new_sample => new_sample,
      new_block  => new_block
   );
   
  comp_aes3rx : entity work.aes3rx
  port map (
    clk    => clk_50m,
    aes3   => slave_aes_data,
    reset  => rst,
    sdata  => open,
    sclk   => open,
    bsync  => open,
    lrck   => open,
    active => open
  );


  
  gen_50m : process
  begin
    while not stop_clk loop
      clk_50m <= '0', '1' after CLK_50M_PERIOD/2;
      wait for CLK_50M_PERIOD;
    end loop;
    wait;
  end process;

  gen_sclk : process
  begin
    while not stop_clk loop
      s_clk <= '0', '1' after S_CLK_PERIOD/2;
      wait for S_CLK_PERIOD;
    end loop;
    wait;
  end process;
  
  process
    variable sample_count : unsigned(23 downto 0) := (others => '0'); 
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait until new_block = '1';
    udata_l <= (others => '1');
    cdata_l <= (others => '1');
    for I in 0 to 191 loop
      sample <= sample_count;
      if sample_count = x"FFFFFF" then
        sample_count := (others <= '0');
      else
        sample_count ;= sample_count + 1;
      end if;
      wait until new_sample = '1';
    wait for 50 ms;
    stop_clk <= true;
    wait;
  end process;
  
  comp_wire_delay : wire_delay
  generic map (
    DELAY => 10 us
  )
  port map (
    wire_in  => master_aes3_data,
    wire_out => slave_aes_data
  );

  
  

end architecture behav;
