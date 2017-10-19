library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package common is    -- untested...

   type state_t is (idle, check_h_addr, check_m_addr, check_s_addr,
						buffer_hours, buffer_minutes, buffer_seconds);
 -- prints a message to the screen
    procedure print(text: string);

    -- prints the message when active
    -- useful for debug switches
    procedure print(active: boolean; text: string);
	 
end Common;

package body common is
   -- prints text to the screen

   procedure print(text: string) is
     variable msg_line: line;
     begin
       write(msg_line, text);
       writeline(output, msg_line);
   end print;




   -- prints text to the screen when active

   procedure print(active: boolean; text: string)  is
     begin
      if active then
         print(text);
      end if;
   end print;
	
end common;