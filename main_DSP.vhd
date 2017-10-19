-- Written by Joe Post

-- It will receive 32 total bits of data:

-- | 8-bit preamble | 24-bit payload | <- data_in
-- MSB 										LSB
--in(31)										in(0)

-- 24-bit payload:

-- | 8-bit hour | 8-bit minute | 8-bit second |
-- MSB 													LSB
--in(23)													in(0)

--each 8-bit byte is just a BCD integer.

--output is just a resetn signal.

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.common.all;

--------------------------------------------------------------
 
entity main_DSP is
generic( hours_addr	:	integer := 252; --0x11111100
			min_addr		:	integer := 253; --0x11111101
			sec_addr		: 	integer := 255	 --0x11111111
			);
port(
	data_in:					in std_logic_vector(7 downto 0);
	sys_clock:				in std_logic;
	hour_1: 					inout std_logic_vector(3 downto 0);
	hour_0: 					inout std_logic_vector(3 downto 0);
	minute_1: 				inout std_logic_vector(3 downto 0);
	minute_0: 				inout std_logic_vector(3 downto 0);
	second_1: 				inout std_logic_vector(3 downto 0);
	second_0: 				inout std_logic_vector(3 downto 0);
	rst		:				in std_logic
--	hours_reg 	: inout std_logic_vector(7 downto 0);
--	minutes_reg : inout std_logic_vector(7 downto 0);
--	seconds_reg : inout std_logic_vector(7 downto 0);
--	state_reg   : inout state_t              := idle

);
end main_DSP;

--------------------------------------------------------------

architecture behav of main_DSP is

type state_t is (idle, check_h_addr, check_m_addr, check_s_addr,
						buffer_hours, buffer_minutes, buffer_seconds);
						
component bcd_to_two_digits
	port ( 
		D : IN std_logic_vector(7 downto 0)  ;
		rst	: in	std_logic;
		Q : OUT unsigned(7 downto 0) );	
	end component;		
	
--registers that are outputs of the BCD converters	 
signal hours : unsigned(7 downto 0);
signal minutes : unsigned(7 downto 0);
signal seconds : unsigned(7 downto 0);

--registers used to buffer inputs to the BCD converters
signal hours_reg : std_logic_vector(7 downto 0); --commented out for debugging 
signal minutes_reg : std_logic_vector(7 downto 0);
signal seconds_reg : std_logic_vector(7 downto 0);

--buffers incoming data
signal data_in_reg	: std_logic_vector(7 downto 0);

--begin state machine in idle
signal state_reg          : state_t              := idle; 

--flash constant to save energy
signal flash	: integer	:= 0;

--buffer for previous data_in value of previous clock cycle
signal data_in_prev_buff	: std_logic_vector(7 downto 0)	:= "00000000";

signal data_in_changed	:	integer	:= 1;
signal change	:  boolean := false;
begin


--the following addresses are necessary to decide which byte of subsequent data goes
--to which lights

	--hours address 	= 0x11111100
	--minutes address = 0x11111110
	--seconds address = 0x11111010
	
	hours_convert:  bcd_to_two_digits
	port map(hours_reg, rst, hours);
	
	minutes_convert:  bcd_to_two_digits
	port map(minutes_reg, rst, minutes);
	
	seconds_convert:  bcd_to_two_digits
	port map(seconds_reg, rst, seconds);
	
		--preamble is OK (should be 0xFF)
		
process(sys_clock, rst, data_in) --I2Cinputbuffer should only output a single changed data_in at a time (i.e., not bit by bit)
	begin
	
	
	if rising_edge(sys_clock) then
	
		if  (data_in /= data_in_prev_buff) then 
			data_in_prev_buff <= data_in; --need to buffer to ensure we're only executing subsequent process based on changes to
													--data_in
--			data_in_changed <= 1;
			change <= TRUE;
		else
			data_in_prev_buff <= data_in_prev_buff; 
			data_in_changed <= data_in_changed;
		end if;

		case state_reg is
         when idle =>
				if(data_in_changed = 1) then
					state_reg <= check_h_addr; --if data_in changes, buffer it and try to see if it matches the 
														--hours 'address'
				elsif(data_in_changed = 2) then
					state_reg <=  check_m_addr;
					
				elsif(data_in_changed = 3) then
					state_reg <= check_s_addr;
				end if;
			when check_h_addr =>				--come here the next clock cycle 
--				if(data_in_changed = '1') then
					if(unsigned(data_in_prev_buff) = hours_addr) then
						state_reg <= buffer_hours; --we have a match, buffer the next byte
						change <= false;
					else
						state_reg <= idle; --no match, check for the minute addr
						data_in_changed <= 2;
					end if;
--				end if;
				
			when check_m_addr => 
				if(unsigned(data_in_prev_buff) = min_addr) then
					state_reg <= buffer_minutes; --we have a match, buffer the next byte
					change <= false;
				else
					state_reg <= idle; --no match, check for the seconds addr
					data_in_changed <= 3;
				end if;
			
			when check_s_addr => 
				if(unsigned(data_in_prev_buff) = sec_addr) then
					state_reg <= buffer_seconds; --we have a match, buffer the next byte
					change <= false;
				else
					state_reg <= idle; --no match, don't do anything
					data_in_changed <= 1;
				end if;
				
			when buffer_hours => 
				if(data_in_changed = 1 and change = true) then
--					hours_reg <= data_in_prev_buff and "01111111"; --may need this to support I2C data format (i.e., lead with a 1 to fit little endian byte)
					hours_reg <= data_in_prev_buff;
					state_reg <= idle;
					data_in_changed <= 1;
					change <= false;
				end if;
				
			when buffer_minutes => 
				if(data_in_changed = 2 and change = true) then
					minutes_reg <= data_in_prev_buff;
					state_reg <= idle;
					data_in_changed <= 1;
					change <= false;
				end if;
				
			when buffer_seconds => 
				if(data_in_changed = 3 and change = true) then
					seconds_reg <= data_in_prev_buff;
					state_reg <= idle;
					data_in_changed <= 1;
					change <= false;
				end if;
	
		end case;
		
		if rst = '0' then
        state_reg <= idle;
--		  slave_addr_OK <= '0'; -- just a debug variable
--      else
--			slave_addr_OK <= '1'; --just a debug point
		end if;
	
		if(rst = '1') then --we have a good signal
			--latch the BCD-converted signals into the output
			hour_0 <= std_logic_vector(hours(3 downto 0)); --hours, minutes, seconds registers
																			--will be latched until next commands
																			--sent from I2C slave, therefore this flash
																			--behavior will be fine
			hour_1 <= std_logic_vector(hours(7 downto 4));
			minute_0 <= std_logic_vector(minutes(3 downto 0));
			minute_1 <= std_logic_vector(minutes(7 downto 4));
			second_0 <= std_logic_vector(seconds(3 downto 0));
			second_1 <= std_logic_vector(seconds(7 downto 4));
--			flash <= 0;
		elsif (rst = '0') then
			hour_0 <= hour_0; --"1111" is an invalid code on CD4082, whereby they'll shut all outputs
			hour_1 <= hour_1;
			minute_0 <= minute_0;
			minute_1 <= minute_1;
			second_0 <= second_0;
			second_1 <= second_1;
--			flash <= 1;
--			hour_0 <= "1111"; --"1111" is an invalid code on CD4082, whereby they'll shut all outputs
--			hour_1 <= "1111";
--			minute_0 <= "1111";
--			minute_1 <= "1111";
--			second_0 <= "1111";
--			second_1 <= "1111";
		end if;		
		
end if;	
end process;
--	
--process(sys_clock, rst)
--	begin
--	if(sys_clock'EVENT and sys_clock = '1' and rst = '1')then
--		
--		if(flash = 1) then --we have a good signal
--			--latch the BCD-converted signals into the output
--			hour_0 <= std_logic_vector(hours(3 downto 0)); --hours, minutes, seconds registers
--																			--will be latched until next commands
--																			--sent from I2C slave, therefore this flash
--																			--behavior will be fine
--			hour_1 <= std_logic_vector(hours(7 downto 4));
--			minute_0 <= std_logic_vector(minutes(3 downto 0));
--			minute_1 <= std_logic_vector(minutes(7 downto 4));
--			second_0 <= std_logic_vector(seconds(3 downto 0));
--			second_1 <= std_logic_vector(seconds(7 downto 4));
--			flash <= 0;
--		elsif (flash = 0) then
--			hour_0 <= "1111"; --"1111" is an invalid code on CD4082, whereby they'll shut all outputs
--			hour_1 <= "1111";
--			minute_0 <= "1111";
--			minute_1 <= "1111";
--			second_0 <= "1111";
--			second_1 <= "1111";
--			flash <= 1;
--		end if;		
--	end if;
--end process;
end architecture;