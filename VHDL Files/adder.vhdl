library ieee;
use work.all;
use ieee.std_logic_1164.all;

entity adder is
port(A,B:in std_logic_vector(15 downto 0);
	  C:out std_logic_vector(15 downto 0));
end entity adder;
architecture compute of adder is
signal carry_a:std_logic_vector(16 downto 0):=(others=>'0');
component Full_Adder is
   port (A, B,Cin: in std_logic; S, Cout: out std_logic);
end component Full_Adder;
begin
add_total:for i in 0 to 15 generate

	s_1:Full_Adder port map(A(i),B(i),carry_a(i),C(i),carry_a(i+1));
end generate;
end architecture ;

