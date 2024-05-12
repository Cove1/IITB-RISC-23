library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkg.all;

entity M69_Pro is
port (clock,reset:in std_logic);
end entity M69_Pro;

architecture cpu of M69_Pro is
    signal pr_1_faltu:std_logic_vector(89 downto 0):=(others => '0');

    signal alu_cmd_in_1:  std_logic_vector(1 downto 0):=(others => '0');
    signal se_sel_6_1,se_sel_9_1,flag_en_ctrl_1,rf_en_ctrl_1,r0_en_ctrl_1,hazard_bit_1 : std_logic:='0';
	 signal pr_en_1:  std_logic_vector(4 downto 0):=(others => '0');
	 signal Prog_mem_1,Data_mem_read_1:  std_logic_vector (15 downto 0):=(others => '0');
	 signal stage_3_ctrl_1:  std_logic_vector (2 downto 0):=(others => '0');
	 signal stage_4_ctrl_1:  std_logic_vector (2 downto 0):=(others => '0');
	 signal stage_5_ctrl_1:  std_logic:='0';
	 signal stage_6_ctrl_1:  std_logic_vector(1 downto 0):=(others => '0');
	 signal alu_c_sig_1,alu_c_reg_1,alu_z_sig_1,alu_z_reg_1:  std_logic:='0';
	 signal Prog_addr_1,Data_addr_1,Data_mem_write_1: std_logic_vector (15 downto 0):=(others => '0');
	 signal pr_1_out_1,pr_2_out_1,pr_3_out_1,pr_4_out_1,pr_5_out_1:  std_logic_vector (89 downto 0):=(others => '0');
	 signal alu_branch_1,stall_reg_in_1: std_logic:='0';
	 signal stall_reg_out_1: std_logic:='0';
	 signal prog_mem_add_1:std_logic_vector(15 downto 0):=(others => '0');
    signal prog_mem_out_1 :std_logic_vector (15 downto 0):=(others => '0');
	 signal Data_mem_in_1,Data_mem_add_1: std_logic_vector(15 downto 0):=(others => '0');
    signal Data_mem_write_en_1 :std_logic:='0';
	 signal Data_mem_out_1 :std_logic_vector (15 downto 0):=(others => '0');
	 signal curr_state_sig:std_logic_vector(2 downto 0):="000";
	
	 signal PR_2_1: std_logic_vector(89 downto 0):=(others => '0');
	
	 signal Op_type_1 :  std_logic_vector(2 downto 0):=(others => '0');
	 signal PR_3_1: std_logic_vector(89 downto 0):=(others => '0');
	 
	 signal ALU_carry_signal_1,ALU_carry_register_1,ALU_zero_signal_1,ALU_zero_register_1 :  std_logic:='0';
	
	 signal OP_ex_type_1: std_logic_vector(2 downto 0):=(others => '0');
	 signal ALU_control_1 :  std_logic_vector(1 downto 0):=(others => '0');
	 signal se_sel_6_ctrl_1,se_sel_9_ctrl_1:  std_logic:='0';
	 signal chutiyap_bit_1,r0_en_out_1: std_logic:='0';
	 signal stall_reg_read_1: std_logic:='0';
	 signal stall_reg_write_1:std_logic:='0';
    signal PR4_1 : std_logic_vector(89 downto 0):=(others => '0');
    signal DMem_WE_1 :  std_logic:='0';
	 
    signal PR5_1 :  std_logic_vector(89 downto 0):=(others => '0');
    signal Op_WB_type_1,opr1_dep_1,opr2_dep_1 :  std_logic_vector(1 downto 0):=(others => '0');
	 signal rf_en_out_1: std_logic:='0';
	 signal pr_en_out_1: std_logic_vector(4 downto 0):=(others => '0');
	 
	 
          
component pipeline is 
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
end component pipeline;

component prog_memory is 
    port (prog_mem_add:in std_logic_vector(15 downto 0);
          Clock,reset :in std_logic;
		    prog_mem_out :out std_logic_vector (15 downto 0)
			 
			 );
end component prog_memory;

component data_memory is 
    port (Data_mem_in,Data_mem_add:in std_logic_vector(15 downto 0);
          Data_mem_write_en,Clock,reset :in std_logic;
		    Data_mem_out :out std_logic_vector (15 downto 0)
			 
			 );
end component data_memory;

component Controller_OR is
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
end component Controller_OR;

component Controller_EX is
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
end component Controller_EX;
component Controller_Mem is
    port(Reset : in std_logic;
         Clock : in std_logic;
         PR4 : in std_logic_vector(89 downto 0);
         DMem_WE : out std_logic);
end component Controller_Mem;

component Controller_WB is
    port(Reset : in std_logic;
         Clock : in std_logic;
         PR5 : in std_logic_vector(89 downto 0);
         Op_WB_type : out std_logic_vector(1 downto 0);
			rf_en_out:out std_logic);
end component Controller_WB;

begin
pipeline_instance: pipeline port map(opr1_dep_1,opr2_dep_1,ALU_control_1,se_sel_6_ctrl_1,se_sel_9_ctrl_1,clock,reset,chutiyap_bit_1,rf_en_out_1,r0_en_out_1,
												ALU_branch_1,pr_en_out_1,prog_mem_out_1,Data_mem_out_1,Op_type_1,OP_ex_type_1,DMem_WE_1,Op_WB_type_1,
												ALU_carry_signal_1,ALU_carry_register_1,ALU_zero_signal_1,ALU_zero_register_1,prog_mem_add_1,
												Data_mem_add_1,Data_mem_write_1,pr_1_faltu,PR_2_1,PR_3_1,PR4_1,PR5_1,ALU_branch_1,stall_reg_out_1,stall_reg_in_1,curr_state_sig);
					
prog_mem_instance: prog_memory port map( prog_mem_add_1,clock,reset,prog_mem_out_1);
data_mem_instance: data_memory port map(Data_mem_write_1,Data_mem_add_1,DMem_WE_1,clock,reset,Data_mem_out_1);
controller_or_instance: Controller_OR port map(reset,PR_2_1,PR_3_1,PR4_1,PR5_1,chutiyap_bit_1,clock,Op_type_1,se_sel_6_ctrl_1,se_sel_9_ctrl_1,opr1_dep_1,opr2_dep_1);
controller_ex_instance: Controller_EX port map(Data_mem_out_1,curr_state_sig,reset,pr_1_faltu,PR_2_1,PR_3_1,clock,ALU_carry_signal_1,ALU_carry_register_1,ALU_zero_signal_1,ALU_zero_register_1,
																ALU_branch_1,OP_ex_type_1,ALU_control_1,chutiyap_bit_1,r0_en_out_1,pr_en_out_1,stall_reg_in_1,stall_reg_out_1);
controller_mem_instance: Controller_Mem port map(reset,clock,PR4_1,DMem_WE_1);
controller_wb_instance: Controller_WB port map(reset,clock,PR5_1,Op_WB_type_1,rf_en_out_1);																
end architecture cpu;
