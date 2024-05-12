library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller_Mem is
    port(Reset : in std_logic;
         Clock : in std_logic;
         PR4 : in std_logic_vector(89 downto 0);
         DMem_WE : out std_logic);
end Controller_Mem;

architecture bhv of Controller_Mem is

begin
mem_proc:process(clock,reset,PR4)
begin
if PR4(31 downto 28) = "0101" then
	if PR4(89)='1' then
		DMem_WE <= '0';
	else
		DMem_WE <= '1';
	end if;
else 
	DMem_WE <= '0';
end if;
end process;
end bhv;





