library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Testbench is
end entity Testbench;

architecture Test of Testbench is

    signal Clock: std_logic := '0';
	 signal reset: std_logic :='1';

    component M69_Pro is
port (clock,reset:in std_logic);
end component M69_Pro;
--	type Memory_data_type is Array (0 to 500) of std_logic_vector(15 downto 0);
--   signal Mem_data,init_data : Memory_data_type := (others=>"0000000000000000");
--	impure function init_mem return Memory_data_type is
--		file text_file : text open read_mode is "C:\Users\arin weling\Desktop\projects\Apple_M69\Memory.txt";
--		variable text_line : line;
--		variable mem_content : Memory_data_type;
--		begin
--			for i in 0 to 500 loop
--				readline(text_file, text_line);
--				read(text_line, mem_content(i));
--			end loop;	
--		return mem_content;
--	end function;
    begin
       -- RF_D3 <= RF_D3 xor "0000000000100010" after 100 ns;
		  --Data_in <= Data_in xor "0000000100000001" after 1000 ns;
        --En <= NOT En after 100 ns;
   process
  begin
--    -- First positive edge
--	init_data<=init_mem;
    wait for 10 ns;
	 reset<='0';
--	 for i in 1 to to_integer(unsigned(init_data(500))) loop
	 for i in 1 to 20 loop
	 wait for 20 ns;
    clock <= '1';
	 wait for 20 ns;
	 clock <='0';
	 end loop;



	
--
--
--
--	
--
--    -- Additional logic or waiting can be added if needed
--
--    -- Optionally, wait forever to stop the process
    wait;
  end process;


		  
        DUT: M69_Pro port map (Clock,reset);
    end Test;