library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller_WB is
    port(Reset : in std_logic;
         Clock : in std_logic;
         PR5 : in std_logic_vector(89 downto 0);
         Op_WB_type : out std_logic_vector(1 downto 0);
			rf_en_out:out std_logic);
end Controller_WB;

architecture bhv of Controller_WB is

    begin        
wb_proc:process(clock,reset,PR5)
begin
case PR5(31 downto 28) is
when "0001" | "0010" =>
	Op_WB_type <= "00";
when "0000" =>
	Op_WB_type <= "01";
when "0011" | "1100" | "1101" =>
	Op_WB_type <= "10";
when "0100" =>
	Op_WB_type <= "11";
when others =>
end case;
end process;

en_proc:process(clock,reset,PR5)
begin
if (PR5(89) = '1' or PR5(31 downto 28) = "0101" or PR5(31 downto 28) = "1111"or PR5(31 downto 28) = "1000"or PR5(31 downto 28) = "1001"or PR5(31 downto 28) = "1010" or PR5(31 downto 28) = "1110")  then
	rf_en_out <= '0';
else 
	rf_en_out <= '1';
end if;
end process;
      

end bhv;


            





