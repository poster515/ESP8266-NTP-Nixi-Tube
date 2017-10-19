-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.0.0 Build 156 04/24/2013 SJ Web Edition"
-- CREATED		"Tue Oct 17 22:21:24 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY main IS 
	PORT
	(
		sys_clock :  IN  STD_LOGIC;
		rst :  IN  STD_LOGIC;
		scl :  INOUT  STD_LOGIC;
		sda :  INOUT  STD_LOGIC;
		data_in :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_to_DSP :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		read_req :  OUT  STD_LOGIC;
		data_valid :  OUT  STD_LOGIC;
		slave_addr_OK :  OUT  STD_LOGIC;
		hour_0 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		hour_1 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		minute_0 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		minute_1 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		second_0 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		second_1 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END main;

ARCHITECTURE bdf_type OF main IS 

COMPONENT main_dsp
GENERIC (hours_addr : INTEGER;
			min_addr : INTEGER;
			sec_addr : INTEGER
			);
	PORT(sys_clock : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 hour_0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 hour_1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute_0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute_1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second_0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second_1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT i2cinputbuffer
GENERIC (SLAVE_ADDR : STD_LOGIC_VECTOR(6 DOWNTO 0)
			);
	PORT(sys_clock : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 scl : INOUT STD_LOGIC;
		 sda : INOUT STD_LOGIC;
		 data_to_master : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 read_req : OUT STD_LOGIC;
		 data_valid : OUT STD_LOGIC;
		 slave_addr_OK : OUT STD_LOGIC;
		 data_from_master : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



b2v_inst : main_dsp
GENERIC MAP(hours_addr => 252,
			min_addr => 253,
			sec_addr => 254
			)
PORT MAP(sys_clock => sys_clock,
		 rst => rst,
		 data_in => data_to_DSP,
		 hour_0 => hour_0,
		 hour_1 => hour_1,
		 minute_0 => minute_0,
		 minute_1 => minute_1,
		 second_0 => second_0,
		 second_1 => second_1);


b2v_inst2 : i2cinputbuffer
GENERIC MAP(SLAVE_ADDR => "1111111"
			)
PORT MAP(sys_clock => sys_clock,
		 rst => rst,
		 scl => scl,
		 sda => sda,
		 data_to_master => data_in,
		 read_req => read_req,
		 data_valid => data_valid,
		 slave_addr_OK => slave_addr_OK,
		 data_from_master => data_to_DSP);


END bdf_type;