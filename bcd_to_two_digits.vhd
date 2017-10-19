LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
Use ieee.numeric_std.all;

ENTITY bcd_to_two_digits IS
generic (
    rst_out	: std_logic_vector(7 downto 0) := "11111111"); --should be 11111111 normally
PORT ( 
	D 				: IN std_logic_vector(7 downto 0);
	rst			: in std_logic;
	Q 				: OUT unsigned(7 downto 0));
END bcd_to_two_digits ;

ARCHITECTURE Behavior OF bcd_to_two_digits IS

BEGIN
--	shift <= D(7 downto 4);
process(D, rst)
begin
	if(rst = '1') then
		if(unsigned(D(7 downto 0))) > 49 then
			Q <= 80 + unsigned(D(7 downto 0)) - 50; -- 80d = "0101 0000" - place the '5' there manually
		elsif (unsigned(D(7 downto 0))) > 39 then
			Q <= 64 + unsigned(D(7 downto 0)) - 40; -- 64d = "0100 0000" - place the '4' there manually
		elsif (unsigned(D(7 downto 0))) > 29 then
			Q <= 48 + unsigned(D(7 downto 0)) - 30; -- 48d = "0011 0000" - place the '3' there manually
		elsif (unsigned(D(7 downto 0))) > 19 then
			Q <= 32 + unsigned(D(7 downto 0)) - 20; -- 32d = "0010 0000" - place the '2' there manually
		elsif (unsigned(D(7 downto 0))) > 9 then
			Q <= 16 + unsigned(D(7 downto 0)) - 10; -- 48d = "0001 0000" - place the '1' there manually
		elsif (unsigned(D(7 downto 0))) >= 0 then
			Q <= unsigned(D);
		else
			Q <= unsigned(rst_out);
		end if;
	elsif (rst = '0') then
		Q <= unsigned(rst_out); --0xFF in hex, an invalid input to the CD4082 chip (i.e., 0xF and 0xF), which will turn off all outputs
	end if;
end process;
END Behavior ;