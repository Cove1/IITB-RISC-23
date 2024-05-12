library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkg.all;

entity pipeline is 
    port (opr_sel_1,opr_sel_2,alu_cmd_in: in std_logic_vector(1 downto 0);
          se_sel_6,se_sel_9,Clock,reset,flag_en_ctrl,rf_en_ctrl,r0_en_ctrl,hazard_bit :in std_logic;
			 pr_en: in std_logic_vector(4 downto 0);
			 Prog_mem,Data_mem_read: in std_logic_vector (15 downto 0);
			 stage_3_ctrl: in std_logic_vector (2 downto 0);
			 stage_4_ctrl: in std_logic_vector (2 downto 0);
			 stage_5_ctrl: in std_logic;
			 stage_6_ctrl: in std_logic_vector(1 downto 0);
			 alu_c_sig,alu_c_reg,alu_z_sig,alu_z_reg: out std_logic;
		    Prog_addr,Data_addr,Data_mem_write:out std_logic_vector (15 downto 0);
			 pr_1_out,pr_2_out,pr_3_out,pr_4_out,pr_5_out: out std_logic_vector (89 downto 0);
			 alu_branch,stall_reg_out:in std_logic;
			 stall_reg_in:out std_logic;
			 curr_state:buffer std_logic_vector(2 downto 0)
			 
			 
			 
			 
			 );
end entity pipeline;

architecture pipe of pipeline is

component sign_extender is 
	port (in_9:in std_logic_vector(8 downto 0);
				in_6:in std_logic_vector(5 downto 0);
				op_sel_6,op_sel_9:in std_logic;
				outp_6_16,outp_9_16:out std_logic_vector(15 downto 0));
end component sign_extender;

component left_shifter is 
	port (in_ls:in std_logic_vector(15 downto 0);
			out_ls:out std_logic_vector(15 downto 0));
end component left_shifter;

component Register_File is
    port (RF_A1,RF_A2,RF_A3,RF_A4: in std_logic_vector(2 downto 0);
          RF_D4,R0_write: in std_logic_vector(15 downto 0);
          R0_en,RF_WE,Clock,reset: in std_logic;
          RF_D1,RF_D2,RF_D3,R0_read: out std_logic_vector(15 downto 0);
			 RF_tot:out Reg_data_type);

end component Register_File;

component Register_90bit is 
       port (Data_in : in std_logic_vector (89 downto 0);
             Write_en,Clock,reset : in std_logic;
		       Data_out : out std_logic_vector (89 downto 0));
end component Register_90bit;


component adder is
port(A,B:in std_logic_vector(15 downto 0);
	  C:out std_logic_vector(15 downto 0));
end component adder;

component alu is
	port (
			alu_cmd: in std_logic_vector(1 downto 0);
			flag_reg: in std_logic_vector(1 downto 0);
			alu_a,alu_b: in std_logic_vector(15 downto 0);
			alu_c: out std_logic_vector(15 downto 0);
			alu_zero,alu_carry: out std_logic);
end component alu;

component Register_2bit is 
       port (Data_in : in std_logic_vector (1 downto 0);
             Write_en,Clock,reset : in std_logic;
		       Data_out : out std_logic_vector (1 downto 0));
end component Register_2bit;
component Register_1bit is 
       port (Data_in : in std_logic;
             Write_en,Clock,reset : in std_logic;
		       Data_out : out std_logic);
end component Register_1bit;
signal flag_reg_write,flag_reg_read: std_logic_vector(1 downto 0):="00";
signal alu_carry,alu_zero,flag_en_ctrl_bar,BLE_disable,lm_sm_pr2_disable:std_logic:='0';
signal adder_3_a,adder_3_b,adder_3_c,alu_a_in,alu_b_in,alu_c_out,r0_read,r0_write,Rf_d1,Rf_d2,Rf_d3,Rf_d4,adder_1_c,adder_2_c,ls_out,se_6_16,se_9_16,
adder_1_a,adder_1_b,adder_2_a,adder_2_b,ls_in,r0_read_sig:std_logic_vector(15 downto 0):="0000000000000000";
signal Reg_data,init_data : Reg_data_type := (others=>"0000000000000000");
signal pr_1_read,pr_2_read,pr_3_read,pr_4_read,pr_5_read,pr_1_write,pr_2_write,pr_3_write,pr_4_write,pr_5_write:std_logic_vector(89 downto 0):=(others => '0');
signal se_9:std_logic_vector(8 downto 0);
signal se_6:std_logic_vector(5 downto 0);
signal Rf_a1,Rf_a2,Rf_a3,Rf_a4: std_logic_vector (2 downto 0);
signal r7_addr,r6_addr,r5_addr,r4_addr,r3_addr,r2_addr,r1_addr,r0_addr:std_logic_vector(5 downto 0):="000000";
signal next_state:std_logic_vector(2 downto 0):="000";
begin
flag_en_ctrl_bar<=(not(flag_en_ctrl)) and not(pr_3_read(89)) and not(BLE_disable) ;
pr_1_out <= pr_1_read;
pr_2_out <= pr_2_read;
pr_3_out <= pr_3_read;
pr_4_out <= pr_4_read;
pr_5_out <= pr_5_read;
alu_c_sig <= alu_carry;
alu_z_sig <= alu_zero;
alu_c_reg <= flag_reg_read(1);
alu_z_reg <= flag_reg_read(0);
flag_reg_write(1) <= alu_carry;
flag_reg_write(0) <= alu_zero;

stall_reg: Register_1bit port map (stall_reg_out,'1',clock,reset,stall_reg_in);
pr_1: Register_90bit port map(pr_1_write,pr_en(0),clock,reset,pr_1_read);
pr_2: Register_90bit port map(pr_2_write,pr_en(1),clock,reset,pr_2_read);
pr_3: Register_90bit port map(pr_3_write,pr_en(2),clock,reset,pr_3_read);
pr_4: Register_90bit port map(pr_4_write,pr_en(3),clock,reset,pr_4_read);
pr_5: Register_90bit port map(pr_5_write,pr_en(4),clock,reset,pr_5_read);
rf: Register_File port map(Rf_a1,Rf_a2,Rf_a3,Rf_a4,Rf_d4,r0_write,r0_en_ctrl,rf_en_ctrl,clock,reset,Rf_d1,Rf_d2,Rf_d3,r0_read,Reg_data);
flag_reg: Register_2bit port map(flag_reg_write,flag_en_ctrl_bar,clock,reset,flag_reg_read);
alu_instance:  alu port map(alu_cmd_in,flag_reg_read,alu_a_in,alu_b_in,alu_c_out,alu_zero,alu_carry);
adder_1: adder port map(r0_read_sig,"0000000000000010",adder_1_c);
adder_2: adder port map(adder_2_a,adder_2_b,adder_2_c);
adder_3: adder port map(adder_3_a,adder_3_b,adder_3_c);
se: sign_extender port map(se_9,se_6,se_sel_6,se_sel_9,se_6_16,se_9_16);
ls: left_shifter port map(ls_in,ls_out);
pr_1_write(89) <= '0';
pr_2_write(89) <= hazard_bit or pr_1_read(89) or lm_sm_pr2_disable;
pr_3_write(89) <= hazard_bit or pr_2_read(89);
pr_4_write(89) <= pr_3_read(89) or flag_en_ctrl;--doubtful, may cause issues
pr_5_write(89) <= pr_4_read(89);
stage_1:process(clock,reset,r0_read,Prog_mem)--removed r0_read_sig

begin
--Stage 1


pr_1_write(15 downto 0) <= Prog_mem;
pr_1_write(31 downto 16) <= r0_read;
end process;

stage_2:process(clock,reset,pr_1_read,curr_state,adder_3_c)
--Stage 2
begin
pr_2_write(31 downto 16) <= pr_1_read(31 downto 16);
if pr_1_read(15 downto 12) ="0110" then
	r7_addr<="000000";
	case curr_state is
		when "000" => 
		pr_2_write(15 downto 0)<="0100111" & pr_1_read(11 downto 9) & r7_addr;
		lm_sm_pr2_disable <= not(pr_1_read(0));
		adder_3_a <= "0000000000" & r7_addr;
		adder_3_b <= "00000000000000" & pr_1_read(0) & '0';
		r6_addr <= adder_3_c(5 downto 0);
		when "001" => 
		pr_2_write(15 downto 0)<="0100110" & pr_1_read(11 downto 9) & r6_addr;
		lm_sm_pr2_disable <= not(pr_1_read(1));
		adder_3_a <= "0000000000" & r6_addr;
		adder_3_b <= "00000000000000" & pr_1_read(1) & '0';
		r5_addr <= adder_3_c(5 downto 0);
		when "010" => 
		pr_2_write(15 downto 0)<="0100101" & pr_1_read(11 downto 9) & r5_addr;
		lm_sm_pr2_disable <= not(pr_1_read(2));
		adder_3_a <= "0000000000" & r5_addr;
		adder_3_b <= "00000000000000" & pr_1_read(2) & '0';
		r4_addr <= adder_3_c(5 downto 0);
		when "011" => 
		pr_2_write(15 downto 0)<="0100100" & pr_1_read(11 downto 9) & r4_addr;
		lm_sm_pr2_disable <= not(pr_1_read(3));
		adder_3_a <= "0000000000" & r4_addr;
		adder_3_b <= "00000000000000" & pr_1_read(3) & '0';
		r3_addr <= adder_3_c(5 downto 0);
		when "100" => 
		pr_2_write(15 downto 0)<="0100011" & pr_1_read(11 downto 9) & r3_addr;
		lm_sm_pr2_disable <= not(pr_1_read(4));
		adder_3_a <= "0000000000" & r3_addr;
		adder_3_b <= "00000000000000" & pr_1_read(4) & '0';
		r2_addr <= adder_3_c(5 downto 0);
		when "101" => 
		pr_2_write(15 downto 0)<="0100010" & pr_1_read(11 downto 9) & r2_addr;
		lm_sm_pr2_disable <= not(pr_1_read(5));
		adder_3_a <= "0000000000" & r2_addr;
		adder_3_b <= "00000000000000" & pr_1_read(5) & '0';
		r1_addr <= adder_3_c(5 downto 0);
		when "110" => 
		pr_2_write(15 downto 0)<="0100001" & pr_1_read(11 downto 9) & r1_addr;
		lm_sm_pr2_disable <= not(pr_1_read(6));
		adder_3_a <= "0000000000" & r1_addr;
		adder_3_b <= "00000000000000" & pr_1_read(6) & '0';
		r0_addr <= adder_3_c(5 downto 0);
		when "111" => 
		pr_2_write(15 downto 0)<="0100000" & pr_1_read(11 downto 9) & r0_addr;
		lm_sm_pr2_disable <= not(pr_1_read(7));
		adder_3_a <= "0000000000" & r7_addr;
		adder_3_b <= "00000000000000" & pr_1_read(7) & '0';
		r7_addr <= "000000";
		when others=>
		r7_addr <= "000000";
		end case;
	elsif  pr_1_read(15 downto 12) ="0111" then
		case curr_state is
		when "000" => 
		pr_2_write(15 downto 0)<="0101111" & pr_1_read(11 downto 9) & r7_addr;
		lm_sm_pr2_disable <= not(pr_1_read(0));
		adder_3_a <= "0000000000" & r7_addr;
		adder_3_b <= "00000000000000" & pr_1_read(0) & '0';
		r6_addr <= adder_3_c(5 downto 0);
		when "001" => 
		pr_2_write(15 downto 0)<="0101110" & pr_1_read(11 downto 9) & r6_addr;
		lm_sm_pr2_disable <= not(pr_1_read(1));
		adder_3_a <= "0000000000" & r6_addr;
		adder_3_b <= "00000000000000" & pr_1_read(1) & '0';
		r5_addr <= adder_3_c(5 downto 0);
		when "010" => 
		pr_2_write(15 downto 0)<="0101101" & pr_1_read(11 downto 9) & r5_addr;
		lm_sm_pr2_disable <= not(pr_1_read(2));
		adder_3_a <= "0000000000" & r5_addr;
		adder_3_b <= "00000000000000" & pr_1_read(2) & '0';
		r4_addr <= adder_3_c(5 downto 0);
		when "011" => 
		pr_2_write(15 downto 0)<="0101100" & pr_1_read(11 downto 9) & r4_addr;
		lm_sm_pr2_disable <= not(pr_1_read(3));
		adder_3_a <= "0000000000" & r4_addr;
		adder_3_b <= "00000000000000" & pr_1_read(3) & '0';
		r3_addr <= adder_3_c(5 downto 0);
		when "100" => 
		pr_2_write(15 downto 0)<="0101011" & pr_1_read(11 downto 9) & r3_addr;
		lm_sm_pr2_disable <= not(pr_1_read(4));
		adder_3_a <= "0000000000" & r3_addr;
		adder_3_b <= "00000000000000" & pr_1_read(4) & '0';
		r2_addr <= adder_3_c(5 downto 0);
		when "101" => 
		pr_2_write(15 downto 0)<="0101010" & pr_1_read(11 downto 9) & r2_addr;
		lm_sm_pr2_disable <= not(pr_1_read(5));
		adder_3_a <= "0000000000" & r2_addr;
		adder_3_b <= "00000000000000" & pr_1_read(5) & '0';
		r1_addr <= adder_3_c(5 downto 0);
		when "110" => 
		pr_2_write(15 downto 0)<="0101001" & pr_1_read(11 downto 9) & r1_addr;
		lm_sm_pr2_disable <= not(pr_1_read(6));
		adder_3_a <= "0000000000" & r1_addr;
		adder_3_b <= "00000000000000" & pr_1_read(6) & '0';
		r0_addr <= adder_3_c(5 downto 0);
		when "111" => 
		pr_2_write(15 downto 0)<="0101000" & pr_1_read(11 downto 9) & r0_addr;
		lm_sm_pr2_disable <= not(pr_1_read(7));
		adder_3_a <= "0000000000" & r7_addr;
		adder_3_b <= "00000000000000" & pr_1_read(7) & '0';
		r7_addr <= "000000";
		when others=>
		r7_addr <= "000000";
		pr_2_write(15 downto 0) <= pr_1_read(15 downto 0);
		lm_sm_pr2_disable <= '0';
		end case;
	else
		pr_2_write(15 downto 0) <= pr_1_read(15 downto 0);
		lm_sm_pr2_disable <= '0';
	end if;
--pr_2_write(15 downto 0) <= pr_1_read(15 downto 0);
--pr_2_write(31 downto 16) <= pr_1_read(31 downto 16);
end process;

stage_3:process(clock,reset,pr_2_read,stage_3_ctrl,ls_out,se_9_16,se_6_16,Rf_d1,Rf_d2)
--Stage 3
begin
pr_3_write(47 downto 32) <= pr_2_read(15 downto 0);
pr_3_write(63 downto 48) <= pr_2_read(31 downto 16);
case stage_3_ctrl is
when "000" => --R type
	
	Rf_a1 <= pr_2_read(11 downto 9);
	Rf_a2 <= pr_2_read(8 downto 6);
	if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
	
	if opr_sel_2="00" then
		pr_3_write(31 downto 16) <= Rf_d2;
	elsif opr_sel_2="01" then
		pr_3_write(31 downto 16) <= alu_c_out;
	elsif opr_sel_2="10" then
		pr_3_write(31 downto 16) <= pr_4_read(15 downto 0);
	else
		pr_3_write(31 downto 16) <= pr_5_read(15 downto 0);
	end if;
	
--	pr_3_write(31 downto 16) <= Rf_d2;
when "001" => --I Type(ADI)
	
	Rf_a1 <= pr_2_read(11 downto 9);
	Rf_a2 <= pr_2_read(8 downto 6);--optional
	se_6 <= pr_2_read(5 downto 0);
	Rf_a1 <= pr_2_read(11 downto 9);
	Rf_a2 <= pr_2_read(8 downto 6);
	if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
	
	pr_3_write(31 downto 16) <= se_6_16;
when "010" => --I Type(LW/SW)
	
	Rf_a1 <= pr_2_read(8 downto 6);
	Rf_a2 <= pr_2_read(8 downto 6);--optional-----------------doubt
	se_6 <= pr_2_read(5 downto 0);
--	pr_3_write(15 downto 0) <= Rf_d1;
	pr_3_write(31 downto 16) <= se_6_16;
	if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
when "011" => --I Type(BLE/BLQ/BLT)
	Rf_a1 <= pr_2_read(11 downto 9);
	Rf_a2 <= pr_2_read(8 downto 6);
--	pr_3_write(15 downto 0) <= Rf_d1;
--	pr_3_write(31 downto 16) <= Rf_d2;
	se_6 <= pr_2_read(5 downto 0);
	ls_in <= se_6_16;
	
	pr_3_write(79 downto 64) <= ls_out;
	if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
	
	if opr_sel_2="00" then
		pr_3_write(31 downto 16) <= Rf_d2;
	elsif opr_sel_2="01" then
		pr_3_write(31 downto 16) <= alu_c_out;
	elsif opr_sel_2="10" then
		pr_3_write(31 downto 16) <= pr_4_read(15 downto 0);
	else
		pr_3_write(31 downto 16) <= pr_5_read(15 downto 0);
	end if;
when "100" => --J Type(JLR)
	
	Rf_a1 <= pr_2_read(8 downto 6);------------------doubt
	Rf_a2 <= pr_2_read(8 downto 6);--optional
--	pr_3_write(15 downto 0) <= Rf_d1;
if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
when "101" => --J Type(JAL)

	Rf_a1 <= pr_2_read(11 downto 9);--optional
	se_9 <= pr_2_read(8 downto 0);
	Rf_a2 <= pr_2_read(8 downto 6);--optional
	ls_in <= se_9_16;
	pr_3_write(15 downto 0) <= ls_out;
when "110" => --J Type(JRI)

	Rf_a1 <= pr_2_read(11 downto 9);
--	pr_3_write(31 downto 16) <= Rf_d1;
if opr_sel_1="00" then
		pr_3_write(15 downto 0) <= Rf_d1;
	elsif opr_sel_1="01" then
		pr_3_write(15 downto 0) <= alu_c_out;
	elsif opr_sel_1="10" then
		pr_3_write(15 downto 0) <= pr_4_read(15 downto 0);
	else
		pr_3_write(15 downto 0) <= pr_5_read(15 downto 0);
	end if;
	Rf_a2 <= pr_2_read(8 downto 6);--optional
	se_9 <= pr_2_read(8 downto 0);
	ls_in <= se_9_16;
	pr_3_write(15 downto 0) <= ls_out;
when others => --J Type(LLI/LHI)

	pr_3_write(15 downto 0) <= pr_2_read(15 downto 0);	-- Don't care

	pr_3_write(31 downto 16) <= pr_2_read(31 downto 16);
	Rf_a2 <= pr_2_read(8 downto 6);--optional	-- Don't care
	Rf_a1 <= pr_2_read(11 downto 9);--optional
end case;
end process;

stage_4:process(clock,reset,pr_3_read,stage_4_ctrl,adder_1_c,adder_2_c,alu_branch,alu_c_out,curr_state)
begin

Prog_addr<=r0_read_sig;
case stage_4_ctrl is
when "000" => -- Rtype 
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
	r0_read_sig <= r0_read;
	BLE_disable <='0';
	if pr_3_read(34)='1' then
		alu_b_in<=not(pr_3_read(31 downto 16));
	else
		alu_b_in<=pr_3_read(31 downto 16);
	end if;
   alu_a_in <= pr_3_read(15 downto 0);
	pr_4_write(15 downto 0)<=alu_c_out;
	r0_write <= adder_1_c;
when "001" => -- ADI/LW/SW
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
	r0_read_sig <= r0_read;
	BLE_disable <='0';
	alu_a_in<=pr_3_read(15 downto 0);
	alu_b_in<=pr_3_read(31 downto 16);
	pr_4_write(15 downto 0)<=alu_c_out;
	r0_write <= adder_1_c;
when "010" => -- BEQ/BLE/BLT
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
	BLE_disable <='1';
	adder_2_a <= pr_3_read(63 downto 48);
	adder_2_b <= pr_3_read(79 downto 64);
	alu_a_in <= pr_3_read(15 downto 0);
	alu_b_in <= pr_3_read(31 downto 16);
	if alu_branch='1' then
		r0_write <= adder_1_c;
		r0_read_sig <= adder_2_c;
		
	else
		r0_write <= adder_1_c;
		r0_read_sig <= r0_read;
	end if;
when "011" => -- JLR
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
BLE_disable <='0';
	adder_2_a <= pr_3_read(63 downto 48);
	adder_2_b <= "0000000000000010";
	pr_4_write(15 downto 0)<=adder_2_c;
	if alu_branch='1' then
		r0_write <= adder_1_c;
		r0_read_sig <= pr_3_read(15 downto 0);
		
	else
		r0_write <= adder_1_c;
		r0_read_sig <= r0_read;
	end if;
when "100" => --JAL
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
BLE_disable <='0';
	adder_2_a <= pr_3_read(63 downto 48);
	adder_2_b <= "0000000000000010";
	pr_4_write(15 downto 0)<=adder_2_c;
	alu_a_in <= pr_3_read(63 downto 48);
	alu_b_in <= pr_3_read(15 downto 0);
	if alu_branch='1' then
		r0_write <= adder_1_c;
		r0_read_sig <= alu_c_out;
		
	else
		r0_write <= adder_1_c;
		r0_read_sig <= r0_read;
	end if;
when "101" => --JRI
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
BLE_disable <='0';
	adder_2_a <= pr_3_read(15 downto 0);
	adder_2_b <= pr_3_read(31 downto 16);
	if alu_branch='1' then
		r0_write <= adder_1_c;
		r0_read_sig <= adder_2_c;
		
	else
		r0_write <= adder_1_c;
		r0_read_sig <= r0_read;
	end if;
	
when "110" => --LLI
pr_4_write(31 downto 16) <= pr_3_read(47 downto 32);
BLE_disable <='0';
	r0_read_sig <= r0_read;
	pr_4_write(15 downto 0) <= "0000000" & pr_3_read(40 downto 32);
	r0_write <= adder_1_c;
--when "111" => --LHI
--	pr_4_write(15 downto 0) <= pr_3_read(40 downto 32) & "0000000";
--	r0_write <= adder_1_c;


when others =>

BLE_disable <='0';
	r0_read_sig<="0000000000000000";
  
end case;
end process;
next_state_defn:process(curr_state)
begin
case curr_state is
when "000" =>
	next_state <= "001";
when "001" =>
	next_state <= "010";
when "010" =>
	next_state <= "011";
when "011" =>
	next_state <= "100";
when "100" =>
	next_state <= "101";
when "101" =>
	next_state <= "110";
when "110" =>
	next_state <= "111";
when "111" =>
	next_state <= "000";
when others =>
	next_state <= "000";
end case;

end process;

stage_transition_proc: process(clock,pr_3_read)
begin
if(clock'event and clock='1') then
	if pr_1_read(15 downto 12)="0110" or pr_1_read(15 downto 12)="0111" then
		curr_state <= next_state;
else
	curr_state<="000";
	end if;
end if;
end process;


stage_5:process(clock,reset,stage_5_ctrl,Rf_d3,Data_mem_read,pr_4_read)--removed Pr4 from sensitivty list
begin
pr_5_write(31 downto 0) <= pr_4_read(31 downto 0);
pr_5_write(89) <= pr_4_read(89);
case stage_5_ctrl is
	when '0' => --LW
		Data_addr<=pr_4_read(15 downto 0);
		pr_5_write(47 downto 32)<=Data_mem_read;
		Rf_a3<=pr_4_read(27 downto 25);
		Data_mem_write<=Rf_d3;
	when '1' => --SW
		Rf_a3<=pr_4_read(27 downto 25);
		Data_mem_write<=Rf_d3;
		Data_addr<=pr_4_read(15 downto 0);
	when others =>
		Data_addr<="0000000000000000";
		Rf_a3<=pr_4_read(27 downto 25);
		Data_mem_write<=Rf_d3;
end case;
end process;

stage_6:process(clock,reset,pr_5_read,stage_6_ctrl)
begin
case stage_6_ctrl is 
	when "00" => --R type
	Rf_d4	<= pr_5_read(15 downto 0);
	Rf_a4 <= pr_5_read(21 downto 19);
	when "01" => --ADI
	Rf_d4	<= pr_5_read(15 downto 0);
	Rf_a4 <= pr_5_read(24 downto 22);
	when "10" => --LLI/JAL/JLR
	Rf_d4	<= pr_5_read(15 downto 0);
	Rf_a4 <= pr_5_read(27 downto 25);
	when "11" => --LW
	Rf_d4	<= pr_5_read(47 downto 32);
	Rf_a4 <= pr_5_read(27 downto 25);
	when others =>
end case;
end process;
	
end architecture;