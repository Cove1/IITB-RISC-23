library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkg.all;

entity data_memory is 
    port (Data_mem_in,Data_mem_add:in std_logic_vector(15 downto 0);
          Data_mem_write_en,Clock,reset :in std_logic;
		    Data_mem_out :out std_logic_vector (15 downto 0)
			 
			 );
end entity data_memory;

architecture behv of data_memory is
 signal Mem_data,init_data : Memory_data_type := (others=>"00000000");
 
begin 

 init_data(0)<="00000000";
 init_data(1)<="00000001";
 init_data(2)<="00000000";
 init_data(3)<="00000010";
 init_data(4)<="00000000";
 init_data(5)<="00000011";

		
		

 
      Data_write: process (reset,Data_mem_in,Clock,Data_mem_add,init_data)
--		Data_write: process (reset,clock)
		begin 
		if (reset = '1') then 
			Mem_data<=init_data;
		else
		if (Clock'event and Clock = '1' and reset='0') then 
			   if (Data_mem_write_en = '1') then 
				   Mem_data(To_integer(unsigned(Data_mem_add))) <= Data_mem_in(15 downto 8) ;
					Mem_data(To_integer(unsigned(Data_mem_add))+1) <= Data_mem_in(7 downto 0) ;
					
				end if ;
			end if;
		end if ;
		end process;
		
      Data_Memory_read : process (Mem_data,Data_mem_add,reset,init_data)
--		Data_Memory_read : process (reset,clock)
		begin 
		   if reset='0' then
			   
--				if((To_integer(unsigned(Data_mem_add))) < 20) then
			   Data_mem_out <= Mem_data(To_integer(unsigned(Data_mem_add))) & Mem_data(To_integer(unsigned(Data_mem_add))+1);
--				else 
--				Data_mem_out <= "1110000000000000";
--				end if;
			else
				Data_mem_out <= init_data(0) & init_data(1);
			end if;
		end process; 
	
end behv ;