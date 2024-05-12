library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is 
	port (in_9:in std_logic_vector(8 downto 0);
				in_6:in std_logic_vector(5 downto 0);
				op_sel_6,op_sel_9:in std_logic;
				outp_6_16,outp_9_16:out std_logic_vector(15 downto 0));
end entity sign_extender;

architecture bhv of sign_extender is

begin
sign_extend:process(op_sel_6,op_sel_9,in_9,in_6)
begin
	
		if(op_sel_9='0') then
			outp_9_16<= "0000000" & in_9;
		else
			outp_9_16<= "1111111" & in_9;
		end if;
		if(op_sel_6='0') then
			outp_6_16<= "0000000000" & in_6;
		else
			outp_6_16<= "1111111111" & in_6;
		end if;
		
end process;
end architecture bhv;
		
