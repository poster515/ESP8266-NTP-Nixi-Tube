----------------------------------------------------------------------------
-- Title      : Main DSP Testbench
-----------------------------------------------------------------------------
-- File       : main_DSP_TB
-- Author     : Joe Post
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.math_real.all;  -- using uniform(seed1,seed2,rand)
use work.common.all;
------------------------------------------------------------------------
entity BCD_TB is
end BCD_TB;
------------------------------------------------------------------------
architecture Testbench of BCD_TB is
  constant T         	: time    := 20 ns;   -- clk period
  signal rst            : std_logic                    := '0';
  signal D              : std_logic_vector(7 downto 0) := (others => '0');
  signal Q              : unsigned(7 downto 0);

	--simulation control
  shared variable ENDSIM       : boolean := false;
  
begin

  ---- Design Under Verification -----------------------------------------
  DUV : entity work.bcd_to_two_digits
    port map( 
			D 		=> D,
			rst	=> rst,
			Q  	=> Q);

  ---- Reset asserted for T/2 ------------------------------
  rst <= '0', '1' after T;

	process
	begin
		
		D <= "00001111"; --hours = 15
		wait for 10 * T;

		D <= "00011111"; --minutes = 15
		wait for 10 * T;

		D <= "00110111"; --minutes = 55
		wait for 10 * T;
		
		ENDSIM := true;
		wait;
  end process;
end Testbench;