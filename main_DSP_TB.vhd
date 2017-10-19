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
entity main_DSP_TB is
end main_DSP_TB;
------------------------------------------------------------------------
architecture Testbench of main_DSP_TB is
  constant T         : time    := 20 ns;   -- clk period

  signal rst             		: std_logic                    := '0';
  signal sys_clock				: std_logic							 := '0'; --
  signal data_in_changed		: integer;
  signal data_in              : std_logic_vector(7 downto 0) := (others => '0');
  
  signal hour_1              	 : std_logic_vector(3 downto 0) := (others => '0');
  signal hour_0              	 : std_logic_vector(3 downto 0) := (others => '0');
  signal minute_1              : std_logic_vector(3 downto 0) := (others => '0');
  signal minute_0              : std_logic_vector(3 downto 0) := (others => '0');
  signal second_1              : std_logic_vector(3 downto 0) := (others => '0');
  signal second_0              : std_logic_vector(3 downto 0) := (others => '0');
  signal change	: boolean := true;

	--simulation control
  shared variable ENDSIM       : boolean := false;
  
  signal hours_reg : std_logic_vector(7 downto 0);
	signal minutes_reg : std_logic_vector(7 downto 0);
	signal seconds_reg : std_logic_vector(7 downto 0);
	signal state_reg	: state_t;
begin

  ---- Design Under Verification -----------------------------------------
  DUV : entity work.main_DSP
    port map (
      data_in			=> data_in,
		sys_clock		=> sys_clock,
		hour_1			=> hour_1,
		hour_0			=> hour_0,
		minute_1			=> minute_1,
		minute_0			=> minute_0,
		second_1			=> second_1,
		second_0			=> second_0,
		rst				=> rst
--		hours_reg 		=> hours_reg,
--		minutes_reg 	=> minutes_reg,
--		seconds_reg 	=> seconds_reg,
--		state_reg   	=> state_reg
		);
		
  ---- DUT clock running forever ----------------------------
  process
  begin
    if ENDSIM = false then
      sys_clock <= '0';
      wait for T/2;
      sys_clock <= '1';
      wait for T/2;
    else
      wait;
    end if;
  end process;

  ---- Reset asserted for T/2 ------------------------------
  rst <= '0', '1' after T;

	process
	begin
		
		
		data_in <= "11111111"; --seconds address
		wait for 10 * T;
		
		data_in <= "00011111"; --seconds = 31
		wait for 10 * T;
		
		data_in <= "11111111"; --seconds address
		wait for 10 * T;
		
		data_in <= "00110111"; --seconds = 55
		wait for 10 * T;
		
		data_in <= "11111111"; --seconds address
		wait for 10 * T;
		
		data_in <= "00000011"; --seconds = 3
		wait for 10 * T;
		
		data_in <= "11111111"; --seconds address
		wait for 10 * T;
		
		data_in <= "00110111"; --seconds = 55
		wait for 10 * T;
		
		data_in <= "11111100"; --hours address
		wait for 10 * T;
		
		data_in <= "00001111"; --hours = 15
		wait for 10 * T;
		
		data_in <= "11111101"; --minutes address
		wait for 10 * T;
		
		data_in <= "00110111"; --minutes = 55
		wait for 10 * T;
		
		ENDSIM := true;
		wait;
  end process;
end Testbench;