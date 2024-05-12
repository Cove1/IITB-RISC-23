library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Controller_EX is
	port (Data_in:in std_logic_vector(15 downto 0);
			curr_state_in:in std_logic_vector(2 downto 0);
			reset:in std_logic;
			PR_1,PR_2,PR_3:in std_logic_vector(89 downto 0);
			clock:in std_logic;
			ALU_carry_signal,ALU_carry_register,ALU_zero_signal,ALU_zero_register : in std_logic;
			ALU_branch: out std_logic;
		   OP_ex_type:out std_logic_vector(2 downto 0);
			ALU_control : out std_logic_vector(1 downto 0);
			chutiyap_bit,r0_en_out : out std_logic;
			pr_en_out:out std_logic_vector(4 downto 0);
			stall_reg_read:in std_logic;
			stall_reg_write:out std_logic);	
end entity Controller_EX;


architecture behv of Controller_EX is 
signal op_code_ex : std_logic_vector(3 downto 0);
signal op_cz_com : std_logic_vector(2 downto 0);
signal BLE_ke_liye : std_logic ;
signal r0_en_out_1,r0_en_out_2,r0_en_out_3,stall_reg_write_1,stall_reg_write_2: std_logic;
signal pr_en_out_1,pr_en_out_2,pr_en_out_3: std_logic_vector(4 downto 0);

begin 
op_code_ex <= PR_3(47 downto 44); 
op_cz_com <= PR_3(34 downto 32);
r0_en_out <= r0_en_out_1 and r0_en_out_2 and r0_en_out_3;
pr_en_out <= pr_en_out_1 and pr_en_out_2 and pr_en_out_3;
stall_reg_write <= stall_reg_write_1 or stall_reg_write_2; 
type_determ : process(clock,reset,PR_3,BLE_ke_liye,ALU_carry_signal,ALU_zero_signal,ALU_zero_register,op_cz_com,ALU_carry_register,op_code_ex)
begin 


chutiyap_bit <= '0';
ALU_branch <= '0';
BLE_ke_liye <= ALU_carry_signal or ALU_zero_signal ; 

Case op_code_ex is 
when "0001" => 
if (op_cz_com ="000") then  -- for ADA 
 op_ex_type <= "000";
 ALU_control <= "00";  -- ADD
elsif (op_cz_com ="100") then  -- for ACA
 op_ex_type <= "000";
 ALU_control <= "00"; -- Add
elsif (op_cz_com ="010") then  -- for ADC
 op_ex_type <= "000";
 ALU_control <= "00"; 
  if (ALU_carry_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif (op_cz_com ="001") then --ADZ
 op_ex_type <= "000";
 ALU_control <= "00"; 
  if (ALU_zero_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif (op_cz_com ="011") then --AWC
  op_ex_type <= "000";
  ALU_control<= "01";
elsif (op_cz_com ="110") then --ACC
  op_ex_type <= "000";
  ALU_control<= "00";
  if (ALU_carry_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif(op_cz_com = "101") then --ACZ
  op_ex_type <= "000";
  ALU_control <= "00"; 
  if (ALU_zero_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if;
elsif(op_cz_com = "111") then --ACW
  op_ex_type <= "000" ; 
  ALU_control <= "01"; --Add with carry
end if; 

when "0000"|"0100"|"0101" =>    --ADI/LW/SW
  op_ex_type <= "001";
  ALU_control <= "00";
  

when "0010" => 
if (op_cz_com ="000") then  -- for NDU
 op_ex_type <= "000";
 ALU_control <= "11";  -- Nand
elsif (op_cz_com ="100") then  -- for NCU
 op_ex_type <= "000";
 ALU_control <= "11"; -- Nand
elsif (op_cz_com ="010") then  -- for NDC
 op_ex_type <= "000";
 ALU_control <= "11"; 
  if (ALU_carry_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif (op_cz_com ="001") then --NDZ
 op_ex_type <= "000";
 ALU_control <= "11"; 
  if (ALU_zero_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif (op_cz_com ="110") then --NCC
  op_ex_type <= "000";
  ALU_control<= "11";
  if (ALU_carry_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if; 
elsif(op_cz_com = "101") then --NCZ
  op_ex_type <= "000";
  ALU_control <= "11"; 
  if (ALU_zero_register = '0')then 
  chutiyap_bit <= '1' ; 
  else 
  chutiyap_bit <= '0';
  end if;
end if ; 

when "1000" => --BEQ
	
  op_ex_type <= "010" ;
  ALU_control <= "10" ; --subtract
  if (ALU_zero_signal = '1') then 
    ALU_branch <= '1' ; 
  else 
	 ALU_branch <= '0';
  end if; 
when "1001" => --BLT
	
  op_ex_type <= "010";
  ALU_control <= "10"; --subtract 
  if (ALU_carry_signal = '1') then 
    ALU_branch <= '1';
  else 
    ALU_branch <= '0';
  end if ; 
when "1010" => --BLE 
  op_ex_type <= "010";
  ALU_control <= "10" ;--subtract
  if (BLE_ke_liye = '1') then 
     ALU_branch <= '1' ; 
  else 
     ALU_branch <= '0' ; 
  end if; 
when "1101" => --JLR 
   op_ex_type <= "011"; 
	ALU_control <= "00"; -- ADD karna padega for address 
	ALU_branch <= '1'; 
when "0011" => --LLI 
   op_ex_type <= "110";
	
	
when "1100" => --JAL 
   op_ex_type <= "100"; 
	ALU_control<= "00"; 
	ALU_branch <= '1'; 
	
when "1111" => --JRI
   op_ex_type <= "101"; 
	ALU_control <= "00";
	ALU_branch <= '1';
when "0110" | "0111" => --LM/SM
	op_ex_type <= "111";
	ALU_control <="00";
	ALU_branch <='0';
	
when others => 
end case ; 
end process; 

ajeeb_dependency_proc_1: process(clock,reset,stall_reg_read,PR_3,PR_2,op_code_ex)
begin
case op_code_ex is
	when "0100" =>
		if PR_2(15 downto 12) = "0001" or PR_2(15 downto 12) = "0010" or PR_2(15 downto 12) = "0000"or PR_2(15 downto 12) = "1000"or PR_2(15 downto 12) = "1001"or PR_2(15 downto 12) = "1010" then
		  if PR_2(11 downto 9) = PR_3(43 downto 41) then
			if stall_reg_read = '0' then
				r0_en_out_1 <= '0';
				pr_en_out_1<="11000";
				stall_reg_write_1 <= '1';
			else
				r0_en_out_1 <= '1';
				pr_en_out_1<="11111";
				stall_reg_write_1 <= '0';
			end if;
			else
			r0_en_out_1 <= '1';
			pr_en_out_1<="11111";
			stall_reg_write_1 <= '0';
			end if;
		 else
			r0_en_out_1 <= '1';
			pr_en_out_1<="11111";
			stall_reg_write_1 <= '0';
		end if;
		if PR_2(15 downto 12) = "0100" or PR_2(15 downto 12) = "0101" or PR_2(15 downto 12) = "1101" then
			if PR_2(8 downto 6) = PR_3(43 downto 41) then
			if stall_reg_read = '0' then
				r0_en_out_1 <= '0';
				pr_en_out_1<="11000";
				stall_reg_write_1 <= '1';
			else
				r0_en_out_1 <= '1';
				pr_en_out_1<="11111";
				stall_reg_write_1 <= '0';
			end if;
			else
			r0_en_out_1 <= '1';
			pr_en_out_1<="11111";
			stall_reg_write_1 <= '0';
			end if;
		 else
			r0_en_out_1 <= '1';
			pr_en_out_1<="11111";
			stall_reg_write_1 <= '0';
		end if;
when others => 
	r0_en_out_1 <= '1';
	pr_en_out_1<="11111";
	stall_reg_write_1 <= '0';
end case;
end process;

ajeeb_dependency_proc_2: process(clock,reset,stall_reg_read,PR_3,PR_2,op_code_ex)
begin
case op_code_ex is
	when "0100" =>
		if PR_2(15 downto 12) = "0001" or PR_2(15 downto 12) = "0010" or PR_2(15 downto 12) = "1000"or PR_2(15 downto 12) = "1001"or PR_2(15 downto 12) = "1010" then
		  if PR_2(8 downto 6) = PR_3(43 downto 41) then
			if stall_reg_read = '0' then
				r0_en_out_2 <= '0';
				pr_en_out_2<="11000";
				stall_reg_write_2 <= '1';
			else
				r0_en_out_2 <= '1';
				pr_en_out_2<="11111";
				stall_reg_write_2 <= '0';
			end if;
			else
			r0_en_out_2 <= '1';
			pr_en_out_2<="11111";
			stall_reg_write_2 <= '0';
			end if;
		 else
			r0_en_out_2 <= '1';
			pr_en_out_2<="11111";
			stall_reg_write_2 <= '0';
		end if;
		if PR_2(15 downto 12) = "1111" then
			if PR_2(11 downto 9) = PR_3(43 downto 41) then
			if stall_reg_read = '0' then
				r0_en_out_2 <= '0';
				pr_en_out_2<="11000";
				stall_reg_write_2 <= '1';
			else
				r0_en_out_2 <= '1';
				pr_en_out_2<="11111";
				stall_reg_write_2 <= '0';
			end if;
		 else
			r0_en_out_2 <= '1';
			pr_en_out_2<="11111";
			stall_reg_write_2 <= '0';
		end if;
		 else
			r0_en_out_2 <= '1';
			pr_en_out_2<="11111";
			stall_reg_write_2 <= '0';
		end if;
when others => 
	r0_en_out_2 <= '1';
	pr_en_out_2<="11111";
	stall_reg_write_2 <= '0';
end case;
end process;
lm_sm_proc:process(curr_state_in,PR_1)
begin
	if PR_1(15 downto 12) = "0110" or PR_1(15 downto 12) = "0111" then
		
		if curr_state_in="111" then
			pr_en_out_3 <= "11111";
			r0_en_out_3 <= '1';
		else
			r0_en_out_3 <= '0';
			pr_en_out_3 <= "11110";
	end if;
	else
		pr_en_out_3 <= "11111";
		r0_en_out_3 <= '1';
	end if;
	
end process;
	
end behv; 
   
  
  
  


  
  
 
