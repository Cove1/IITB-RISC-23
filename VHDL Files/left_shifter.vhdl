library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity left_shifter is 
	port (in_ls:in std_logic_vector(15 downto 0);
			out_ls:out std_logic_vector(15 downto 0));
end entity left_shifter;

architecture left_shift of left_shifter is 
begin
out_ls(15 downto 1)<=in_ls(14 downto 0);
out_ls(0)<='0';
end architecture left_shift;