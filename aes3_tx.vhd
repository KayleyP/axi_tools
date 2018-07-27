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
entity aes3_tx is
  port (
    s_clk : in std_logic;
    rst : in std_logic;
    udata_l : in std_logic_vector(191 downto 0);
    udata_r : in std_logic_vector(191 downto 0);
    cdata_l : in std_logic_vector(191 downto 0);
    cdata_r : in std_logic_vector(191 downto 0);
    sample : in std_logic_vector(23 downto 0);
    aes_data : out std_logic;
    new_sample : out std_logic;
    new_block : out std_logic
  );
end entity aes3_tx;

architecture rtl of aes3_tx is
  type states is (S_RESET, S_PREAMBLE, S_DATA);
  signal sm_state : states := S_RESET;
  
  constant AES_BLOCK_PREAMBLE : std_logic_vector(7 downto 0) := "11101000";
  constant AES_RIGHT_PREAMBLE : std_logic_vector(7 downto 0) := "11100100";
  constant AES_LEFT_PREAMBLE : std_logic_vector(7 downto 0) := "11100010";
  
  signal b_clk, lr_clk : std_logic := '1';
  signal lr_fe, lr_re : std_logic := '0';
  signal lr_count : integer range 0 to 127 := 0;
  
  signal block_count : integer range 0 to 511 := 0;
  signal s_count : integer range 0 to 63 := 0;
  
  signal aes_sr : std_logic_vector(31 downto 0) := (others => '0');
  signal aes_preamble : std_logic_vector(7 downto 0);
  signal aes_data_i : std_logic := '0';
  
  signal aes_udata_l : std_logic_vector(191 downto 0);
  signal aes_udata_r : std_logic_vector(191 downto 0);
  signal aes_cdata_l : std_logic_vector(191 downto 0);
  signal aes_cdata_r : std_logic_vector(191 downto 0);
  signal aes_sample : std_logic_vector(23 downto 0);

begin


  process(s_clk)
  begin
    if rising_edge(s_clk) then
      b_clk <= not b_clk;
    end if;
  end process;
  
  process(s_clk)
  begin
    if rising_edge(s_clk) then
      if lr_count = 63 then
        lr_clk <= '0';
        lr_fe <= '1';
        lr_count <= lr_count + 1;
      elsif lr_count = 127 then
        lr_clk <= '1';
        lr_count <= 0;
        lr_re <= '1';
      else
        lr_count <= lr_count + 1;
        lr_re <= '0';
        lr_fe <= '0';
      end if;
    end if;
  end process;
  
  process(s_clk)
  begin
    if rising_edge(s_clk) then
      if lr_re = '1' then
        -- First left channel block
        if block_count = 0 then
          aes_udata_l <= udata_l;
          aes_cdata_l <= cdata_l;
          aes_udata_r <= udata_r;
          aes_cdata_r <= cdata_r;
        else
          aes_udata_l <= aes_udata_l(190 downto 0) & '0';
          aes_cdata_l <= aes_cdata_l(190 downto 0) & '0';
          aes_udata_r <= aes_udata_r(190 downto 0) & '0';
          aes_cdata_r <= aes_cdata_r(190 downto 0) & '0';
        end if;
      end if;
    end if;
  end process;
        

  process(s_clk)
  function PARITY (X : std_logic_vector)
                 return std_logic is
  variable TMP : std_logic := '0';
  begin
    for J in X'range loop
      TMP := TMP xor X(J);
    end loop; -- works for any size X
    return TMP;
  end PARITY;
  begin
    if rising_edge(s_clk) then
      if lr_re = '1' then
        aes_sr <= (others => '1');
        --aes_sr <= x"0" & sample & '0' & aes_udata_l(191) & aes_cdata_l(191) & PARITY(sample & '0' & aes_udata_l(191) & aes_cdata_l(191));
      elsif lr_fe = '1' then
        aes_sr <= (others => '0');
        --aes_sr <= x"0" & sample & '0' & aes_udata_r(191) & aes_cdata_r(191) & PARITY(sample & '0' & aes_udata_r(191) & aes_cdata_r(191));
      elsif b_clk = '0' then
        aes_sr <= aes_sr(30 downto 0) & '0';
      end if;
    end if;
  end process;
  
  process(s_clk)
    variable last_pol : std_logic := '0';
  begin
    if rising_edge(s_clk) then
      if rst = '1' then
        sm_state <= S_RESET;
      else
        case sm_state is
        when S_RESET => 
          if lr_re = '1' then
            aes_data_i <= not aes_preamble(7-s_count);
            s_count <= 0;
            sm_state <= S_PREAMBLE;
          end if;
          
        when S_PREAMBLE =>
          if last_pol = '1' then
            aes_data_i <= not aes_preamble(7-s_count);
          else
            aes_data_i <= aes_preamble(7-s_count);
          end if;
          
          s_count <= s_count + 1;
          if s_count = 7 then
            s_count <= 0;
            sm_state <= S_DATA;
          end if;
          
        when S_DATA =>
          if b_clk = '0' then
            aes_data_i <= not aes_data_i;
            last_pol := not aes_data_i;
          elsif aes_sr(aes_sr'left) = '1' then
            aes_data_i <= not aes_data_i;
            last_pol := not aes_data_i;
          end if;
          if s_count = 55 then
            if block_count = 383 then 
              block_count <= 0;
            else
              block_count <= block_count + 1;
            end if;
            s_count <= 0;
            sm_state <= S_PREAMBLE;
          else
            s_count <= s_count + 1;
          end if;
        end case;
      end if;
    end if;
  end process;

  aes_data <= aes_data_i;
  new_sample <= lr_re or lr_fe;
  new_block <= '1' when lr_re = '1' and block_count = 0 else '0';
          
  aes_preamble <= AES_BLOCK_PREAMBLE when block_count = 0 and lr_clk = '1' else  
                  AES_RIGHT_PREAMBLE when lr_clk = '0' else
                  AES_LEFT_PREAMBLE;
  --aes_preamble <= (others => '1');
end architecture rtl;