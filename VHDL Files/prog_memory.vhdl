library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkg.all;

entity prog_memory is 
    port (prog_mem_add:in std_logic_vector(15 downto 0);
          Clock,reset :in std_logic;
		    prog_mem_out :out std_logic_vector (15 downto 0)
			 
			 );
end entity prog_memory;

architecture behv of prog_memory is
 signal Pro_data,init_pro_data : Memory_data_type := (others=>"10100000");
 
begin 

 init_pro_data(2)<="11000010";
 init_pro_data(3)<="00000111";
 init_pro_data(4)<="00010111";
 init_pro_data(5)<="00101000";
-- init_pro_data(6)<="00010111";
-- init_pro_data(7)<="01110011";
-- init_pro_data(8)<="00010111";
-- init_pro_data(9)<="01110011";
-- init_pro_data(16)<="00011001";
-- init_pro_data(17)<="01110000";
 init_pro_data(18)<="00011001";
 init_pro_data(19)<="01110000";

		
		

 
      prog_mem_init: process (Clock,reset,init_pro_data)
--		prog_mem_init: process (Clock,reset)
		begin 
		if (reset = '1') then 
			Pro_data<=init_pro_data;
		end if ;
		
		end process;
		
      Prog_Memory_read : process (Pro_data,clock,reset,Prog_mem_add,init_pro_data)
--		Prog_Memory_read : process (clock,reset)
		begin 
		if (reset='0') then
--		      if((To_integer(unsigned(Prog_mem_add))) < 20) then
			   Prog_mem_out <= Pro_data(To_integer(unsigned(Prog_mem_add))) & Pro_data(To_integer(unsigned(Prog_mem_add))+1);
--				else 
--				Prog_mem_out <= "1110000000000000";
--				end if;
		else 
				Prog_mem_out <= init_pro_data(0) & init_pro_data(1);
		end if;
		end process; 
end behv;
	