library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
package pkg is
	type Reg_data_type is Array (0 to 7) of std_logic_vector(15 downto 0);
	type Memory_data_type is Array (0 to 200) of std_logic_vector(7 downto 0);
end package;

package body pkg is
end package body;
