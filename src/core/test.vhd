
library ieee;
use ieee.std_logic_1164.all;

entity test_and is
	port (
		a : in  std_logic;
		b : in  std_logic;
		y : out std_logic
	);
end entity test_and;

architecture rtl of test_and is

begin

	y <= a and b;

end architecture rtl;

