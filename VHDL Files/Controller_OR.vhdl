library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller_OR is
	port (reset:in std_logic;
			PR_2:in std_logic_vector(89 downto 0);
			PR_3:in std_logic_vector(89 downto 0);
			PR_4:in std_logic_vector(89 downto 0);
			PR_5:in std_logic_vector(89 downto 0);
			chutiyap_cntrl_EX : in std_logic; 
			clock:in std_logic;
			Op_type : out std_logic_vector(2 downto 0);
			se_sel_6_ctrl,se_sel_9_ctrl: out std_logic;
			opr1_dep,opr2_dep : out std_logic_vector(1 downto 0) );
end entity Controller_OR;

architecture behv of Controller_OR is 
signal op_state : std_logic_vector(3 downto 0);
signal op_state_PR3 : std_logic_vector(3 downto 0);
signal op_state_PR4 : std_logic_vector(3 downto 0);
signal op_state_PR5 : std_logic_vector(3 downto 0);
signal opr_1 : std_logic_vector(2 downto 0);
signal opr_2 : std_logic_vector(2 downto 0);
signal regc_PR3 : std_logic_vector(2 downto 0);
signal regb_PR3 : std_logic_vector(2 downto 0);
signal rega_PR3 : std_logic_vector(2 downto 0);
signal regc_PR4 : std_logic_vector(2 downto 0);
signal regb_PR4 : std_logic_vector(2 downto 0);
signal rega_PR4 : std_logic_vector(2 downto 0);
signal regc_PR5 : std_logic_vector(2 downto 0);
signal regb_PR5 : std_logic_vector(2 downto 0);
signal rega_PR5 : std_logic_vector(2 downto 0);
signal dep_change_opr1 : std_logic;
signal dep_change_opr2 : std_logic;

begin 

OP_division : process (clock,reset,PR_2,op_state)


begin 
op_state <= PR_2(15 downto 12);
op_state_PR3 <= PR_3(47 downto 44);
regc_PR3 <= PR_3(37 downto 35);
regb_PR3 <= PR_3(40 downto 38);
rega_PR3 <= PR_3(43 downto 41); 
op_state_PR4 <= PR_4(31 downto 28);
regc_PR4 <= PR_4(21 downto 19);
regb_PR4 <= PR_4(24 downto 22);
rega_PR4 <= PR_4(27 downto 25); 
op_state_PR5 <= PR_5(31 downto 28);
regc_PR5 <= PR_5(21 downto 19);
regb_PR5 <= PR_5(24 downto 22);
rega_PR5 <= PR_5(27 downto 25);  
opr_1 <= PR_2(11 downto 9);
opr_2 <= PR_2(8 downto 6); 
 
Case op_state is 
when "0001"|"0010" => 
 Op_type <= "000";
when "0000" => 
 Op_type <= "001";
 if PR_2(5) = '1' then
	se_sel_6_ctrl <= '1';
	else 
	se_sel_6_ctrl <= '0';
	end if;
when "0100"|"0101" => 
	if PR_2(5) = '1' then
	se_sel_6_ctrl <= '1';
	else 
	se_sel_6_ctrl <= '0';
	end if;
 Op_type <= "010";
when "1000"|"1001"|"1010" => 
 if PR_2(5) = '1' then
	se_sel_6_ctrl <= '1';
	else 
	se_sel_6_ctrl <= '0';
	end if;
 Op_type <= "011";
when "1100" => 
 Op_type <= "100";
 if PR_2(8) = '1' then
	se_sel_9_ctrl <= '1';
	else 
	se_sel_9_ctrl <= '0';
	end if;
when "1101" => 
 Op_type <= "101";
when "1111" => 
 Op_type <= "110";
 if PR_2(8) = '1' then
	se_sel_9_ctrl <= '1';
	else 
	se_sel_9_ctrl <= '0';
	end if;
when "0011" => 
 se_sel_9_ctrl <= '0';
 Op_type <= "111";
when others =>
end case; 
end process;

data_forwarding : process (clock,reset,op_state,PR_3,PR_4,PR_5,op_state_PR3,op_state_PR4,op_state_PR5,opr_1,opr_2,
									regc_PR3,regb_PR3,rega_PR3,
									regc_PR4,regb_PR4,rega_PR4,
									regc_PR5,regb_PR5,rega_PR5)-- outputs opr1_dep and opr2_dep
begin
dep_change_opr1<= '0';
dep_change_opr2<= '0'; 
Case op_state is 
When "0001"|"0010"|"1000"|"1001"|"1010" => --R-type and BEQ/BLT/BLE because all these insturctions require OPR1 and OPR2
if ( op_state_PR3 = "0001") or (op_state_PR3 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR3) then 
     opr1_dep <= "01"; -- take data from execution stage as output of ALU
     dep_change_opr1 <= '0';
  else 
     opr1_dep <= "00"; -- no data dependancy 
  end if ; 
 if (opr_2 = regc_PR3) then 
     opr2_dep <= "01"; -- take data from execution stage as output of ALU
	   dep_change_opr2 <= '1';
  else 
     opr2_dep <= "00"; -- no data dependancy 
  end if ;  
elsif (op_state_PR3 = "0000") then --ADI REG-B is changing 
   if (opr_1 = regb_PR3) then 
	   opr1_dep <= "01";
		 dep_change_opr1 <= '1';
	else 
	   opr1_dep <= "00";
	end if ;
	if (opr_2 = regb_PR3) then 
	   opr2_dep <= "01"; --ALU se output 
		 dep_change_opr2 <= '1';
	else 
	   opr2_dep <= "00";
	end if ;

elsif (op_state_PR3 = "1100") then --JAL REG-A is changing (JLR ka adder_c se lena padega ) and LLI ko ignore mara abe ke liye 
  if (opr_1 = rega_PR3) then 
	   opr1_dep <= "01";
		 dep_change_opr1 <= '1';
	else 
	   opr1_dep <= "00";
	end if ;
	if (opr_2 = rega_PR3) then 
	   opr2_dep <= "01";
		 dep_change_opr2 <= '1';
	else 
	   opr2_dep <= "00";
	end if ;
end if; 


if ( op_state_PR4 = "0001") or (op_state_PR4 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = regc_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
elsif (op_state_PR4 = "0000") then --ADI REG-B is changing 
 if (opr_1 = regb_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = regb_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
elsif (op_state_PR4 = "1100") or (op_state_PR4 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_1 = rega_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = rega_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
end if; 


if ( op_state_PR5 = "0001") or (op_state_PR5 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = regc_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
elsif (op_state_PR5 = "0000") then --ADI REG-B is changing 
 if (opr_1 = regb_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = regb_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
elsif (op_state_PR5 = "1100") or (op_state_PR5 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_1 = rega_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 if (opr_2 = rega_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
end if; 

when "0000"|"0101"|"1111" => --requires OPR1

if ( op_state_PR3 = "0001") or (op_state_PR3 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR3) then 
     opr1_dep <= "01"; -- take data from execution stage as output of ALU
     dep_change_opr1 <= '1';
  else 
     opr1_dep <= "00"; -- no data dependancy 
  end if ; 
   
elsif (op_state_PR3 = "0000") then --ADI REG-B is changing 
   if (opr_1 = regb_PR3) then 
	   opr1_dep <= "01";
		 dep_change_opr1 <= '1';
	else 
	   opr1_dep <= "00";
	end if ;
	

elsif (op_state_PR3 = "1100") then --JAL REG-A is changing (JLR ka adder_c se lena padega ) and LLI ko ignore mara abe ke liye 
  if (opr_1 = rega_PR3) then 
	   opr1_dep <= "01";
		 dep_change_opr1 <= '1';
	else 
	   opr1_dep <= "00";
	end if ;
	
end if; 


if ( op_state_PR4 = "0001") or (op_state_PR4 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 

elsif (op_state_PR4 = "0000") then --ADI REG-B is changing 
 if (opr_1 = regb_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR4 = "1100") or (op_state_PR4 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_1 = rega_PR4) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 
end if; 


if ( op_state_PR5 = "0001") or (op_state_PR5 = "0010") then --Reg-C is changing in these instructions
 if (opr_1 = regc_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR5 = "0000") then --ADI REG-B is changing 
 if (opr_1 = regb_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR5 = "1100") or (op_state_PR5 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_1 = rega_PR5) then 
   if (dep_change_opr1 = '0') then 
	  opr1_dep <= "11"; -- take data from PR4(15 downto 0)
     dep_change_opr1 <= '1'; 
  end if ; 
  end if ; 
 
end if; 

when "1101" => --requires OPR2

if ( op_state_PR3 = "0001") or (op_state_PR3 = "0010") then --Reg-C is changing in these instructions
 if (opr_2 = regc_PR3) then 
     opr2_dep <= "01"; -- take data from execution stage as output of ALU
     dep_change_opr2 <= '1';
  else 
     opr2_dep <= "00"; -- no data dependancy 
  end if ; 
 
elsif (op_state_PR3 = "0000") then --ADI REG-B is changing 
   if (opr_2 = regb_PR3) then 
	   opr2_dep <= "01";
		 dep_change_opr2 <= '1';
	else 
	   opr2_dep <= "00";
	end if ;
	

elsif (op_state_PR3 = "1100") then --JAL REG-A is changing (JLR ka adder_c se lena padega ) and LLI ko ignore mara abe ke liye 
  if (opr_2 = rega_PR3) then 
	   opr2_dep <= "01";
		 dep_change_opr2 <= '1';
	else 
	   opr2_dep <= "00";
	end if ;
	
end if; 


if ( op_state_PR4 = "0001") or (op_state_PR4 = "0010") then --Reg-C is changing in these instructions
 if (opr_2 = regc_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 

elsif (op_state_PR4 = "0000") then--ADI REG-B is changing 
 if (opr_2 = regb_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR4 = "1100") or (op_state_PR4 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_2 = rega_PR4) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "10"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
 
end if; 


if ( op_state_PR5 = "0001") or (op_state_PR5 = "0010") then --Reg-C is changing in these instructions
 if (opr_2 = regc_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR5 = "0000") then--ADI REG-B is changing 
 if (opr_2 = regb_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR5(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
 
elsif (op_state_PR5 = "1100") or (op_state_PR5 = "1101") then --JAL/JLR REG-A is changing isme we can use JLR as well. 
 if (opr_2 = rega_PR5) then 
   if (dep_change_opr2 = '0') then 
	  opr2_dep <= "11"; -- take data from PR4(15 downto 0)
     dep_change_opr2 <= '1'; 
  end if ; 
  end if ; 
 
end if; 
when others => 
opr1_dep <= "00";
opr2_dep <= "00";
end case;
end process;

end behv; 