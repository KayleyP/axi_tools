
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
entity wire_delay is
  generic(
    DELAY : time := 0 ns
  );
  port (
      wire_in : in std_logic;
      wire_out : out std_logic
  );
end entity wire_delay;

architecture behav of wire_delay is

begin

  process(wire_in)
  begin
    wire_out <= transport wire_in after DELAY;
  end process;
  
end architecture behav;