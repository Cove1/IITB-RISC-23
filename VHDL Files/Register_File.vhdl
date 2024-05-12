library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.pkg.all;

entity Register_File is
    port (RF_A1,RF_A2,RF_A3,RF_A4: in std_logic_vector(2 downto 0);
          RF_D4,R0_write: in std_logic_vector(15 downto 0);
          R0_en,RF_WE,Clock,reset: in std_logic;
          RF_D1,RF_D2,RF_D3,R0_read: out std_logic_vector(15 downto 0);
			 RF_tot:out Reg_data_type);

end entity Register_File;

architecture bhv_RF of Register_File is
	
   signal Reg_data,init_data : Reg_data_type := (others=>"0000000000000000");
--	impure function init_reg return Reg_data_type is
--		file text_file : text open read_mode is "C:\Users\arin weling\Desktop\projects\Apple_M69\Register.txt";
--		variable text_line : line;
--		variable reg_content : Reg_data_type;
--		begin
--			for i in 0 to 7 loop
--				readline(text_file, text_line);
--				read(text_line, reg_content(i));
--			end loop;	
--		return reg_content;
--	end function;
----Initialising values -> not necessary, but for checking purposes
    signal   R0_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R1_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R2_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R3_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R4_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R5_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R6_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal   R7_in : std_logic_vector (15 downto 0):="0000000000000000";
	 signal R0_out : std_logic_vector(15 downto 0);
	 signal R1_out : std_logic_vector(15 downto 0);
	 signal R2_out : std_logic_vector(15 downto 0);
	 signal R3_out : std_logic_vector(15 downto 0);
	 signal R4_out : std_logic_vector(15 downto 0);
	 signal R5_out : std_logic_vector(15 downto 0);
	 signal R6_out : std_logic_vector(15 downto 0);
	 signal R7_out : std_logic_vector(15 downto 0);
    component Register_16bit is 
       port (Data_in : in std_logic_vector (15 downto 0);
             Write_en,Clock,reset : in std_logic;
		       Data_out : out std_logic_vector (15 downto 0));
    end component Register_16bit;
	signal en:std_logic_vector(7 downto 0):="00000000";
    begin
		 init_data(0)<="0000000000000000";
		 init_data(1)<="0000000000000010";
		 init_data(2)<="0000000000000010";
		 init_data(3)<="0000000000000000";
		 init_data(4)<="0000000000000001";
		 init_data(5)<="0000000000000010";
		 init_data(6)<="0000000000000000";
		 init_data(7)<="0000000000000000";
		 
		
        R0: Register_16bit port map (Data_in => R0_write , Write_en => R0_en, Clock => Clock ,reset => reset, Data_out => R0_out);
		  R1: Register_16bit port map (Data_in => R1_in , Write_en => en(1), Clock => Clock ,reset => reset, Data_out => R1_out);
		  R2: Register_16bit port map (Data_in => R2_in , Write_en => en(2), Clock => Clock ,reset => reset, Data_out => R2_out);
		  R3: Register_16bit port map (Data_in => R3_in , Write_en => en(3), Clock => Clock ,reset => reset, Data_out => R3_out);
		  R4: Register_16bit port map (Data_in => R4_in , Write_en => en(4), Clock => Clock ,reset => reset, Data_out => R4_out);
		  R5: Register_16bit port map (Data_in => R5_in , Write_en => en(5), Clock => Clock ,reset => reset, Data_out => R5_out);
		  R6: Register_16bit port map (Data_in => R6_in , Write_en => en(6), Clock => Clock ,reset => reset, Data_out => R6_out);
		  R7: Register_16bit port map (Data_in => R7_in , Write_en => en(7), Clock => Clock ,reset => reset, Data_out => R7_out);
       ----writing process  
		 RF_tot(0)<=R0_out;
		 RF_tot(1)<=R1_out;
		 RF_tot(2)<=R2_out;
		 RF_tot(3)<=R3_out;
		 RF_tot(4)<=R4_out;
		 RF_tot(5)<=R5_out;
		 RF_tot(6)<=R6_out;
		 RF_tot(7)<=R7_out;
		 R0_read <= R0_out;
		 
		 
		 write_reg : process ( RF_D4,RF_A4,Clock,reset,init_data,RF_WE,R0_en)
		 begin
		if(reset='1')then
			en<="00000000";
			R0_in<=init_data(0);
			R1_in<=init_data(1);
			R2_in<=init_data(2);
			R3_in<=init_data(3);
			R4_in<=init_data(4);
			R5_in<=init_data(5);
			R6_in<=init_data(6);
			R7_in<=init_data(7);
--		elsif (clock'event and clock = '1') then 
		    elsif (RF_WE = '1') then 
		      case RF_A4 is 
			     when "000" =>
				    R0_in<=RF_D4;
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="00000001";
				  when "001" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					en<="0000001" & R0_en;
				  when "010" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="0000010" & R0_en;
				  when "011" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="0000100" & R0_en;
				  when "100" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="0001000" & R0_en;
				  when "101" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="00100000";
				  when "110" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="0100000" & R0_en;
				  when "111" =>
				    
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					 en<="1000000" & R0_en;
					--- some random case-> it wasnt working otherwise :>
				  when others =>
				  
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					en<="00000001";
				
				    
				end case;
				else
					R0_in<=RF_D4;
					R1_in<=RF_D4;
					R2_in<=RF_D4;
					R3_in<=RF_D4;
					R4_in<=RF_D4;
					R5_in<=RF_D4;
					R6_in<=RF_D4;
					R7_in<=RF_D4;
					en<="00000001";
			  end if;
		 end process;
		 read_reg : process (RF_A1,RF_A2,R0_out,R1_out,R2_out,R3_out,R4_out,R5_out,R6_out,R7_out,RF_A3)
		 begin 
		   case RF_A1 is 
			     when "000" =>
				    RF_D1 <= R0_out;
				  when "001" =>
				    RF_D1 <= R1_out;
				  when "010" =>
				    RF_D1 <= R2_out;
				  when "011" =>
				    RF_D1 <= R3_out;
				  when "100" =>
				    RF_D1 <= R4_out;
				  when "101" =>
				    RF_D1 <= R5_out;
				  when "110" =>
				    RF_D1 <= R6_out;
				  when "111" =>
				    RF_D1 <= R7_out;
				--random ass case 
				  when others =>
				    
				end case;
			case RF_A2 is 
			     when "000" =>
				    RF_D2 <= R0_out;
				  when "001" =>
				    RF_D2 <= R1_out;
				  when "010" =>
				    RF_D2 <= R2_out;
				  when "011" =>
				    RF_D2 <= R3_out;
				  when "100" =>
				    RF_D2 <= R4_out;
				  when "101" =>
				    RF_D2 <= R5_out;
				  when "110" =>
				    RF_D2 <= R6_out;
				  when "111" =>
				    RF_D2 <= R7_out;
				---random ass case 
				  when others =>
				    
				end case;
			case RF_A3 is 
			     when "000" =>
				    RF_D3 <= R0_out;
				  when "001" =>
				    RF_D3 <= R1_out;
				  when "010" =>
				    RF_D3 <= R2_out;
				  when "011" =>
				    RF_D3 <= R3_out;
				  when "100" =>
				    RF_D3 <= R4_out;
				  when "101" =>
				    RF_D3 <= R5_out;
				  when "110" =>
				    RF_D3 <= R6_out;
				  when "111" =>
				    RF_D3 <= R7_out;
				---random ass case 
				  when others =>
				    
				end case;
			end process;
		end bhv_RF;
		  