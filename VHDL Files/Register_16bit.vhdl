library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
Entity Register_16bit is 
       port (Data_in : in std_logic_vector (15 downto 0);
             Write_en,Clock,reset : in std_logic;
		       Data_out : out std_logic_vector (15 downto 0));
end entity Register_16bit;

architecture behv of Register_16bit is

       signal data : std_logic_vector (15 downto 0):="0000000000000000";
begin 

     data_write : process (clock,Data_in,reset)
	  begin 
			if(reset='1')then
				data<=Data_in;			
	      elsif (clock'event and clock = '1')  then 
			     if (Write_en = '1') then 
	               data<= Data_in;
	           end if ;
			end if;
			
	  end process ;
	  Data_out <= data;
	  
end behv ;
	  
   
        


