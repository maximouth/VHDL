LIBRARY ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


-- declaration de l'addaccu
ENTITY addaccu IS
	PORT(
		a,b : in std_logic_vector(3 downto 0);
		clk, sel: in std_logic;
		S: out std_logic_vector(3 downto 0)
	);
END addaccu;

-- description de l'addaccu
architecture dataflow of addaccu is
 signal MUX_OUT : std_logic_vector (3 downto 0) := "0000";
 signal ACCU : std_logic_vector (3 downto 0) := "0000";
 signal ALU_OUT :std_logic_vector (3 downto 0) := "0000";
begin

 MUX_OUT <= A(3 downto 0) when SEL = '0' else ACCU(3 downto 0);        
 ALU_OUT <=  std_Logic_Vector (unsigned (MUX_OUT) + unsigned (B));
 S <= ALU_OUT;

process (clk)
begin  
  if CLK = '1' then
    ACCU(3 downto 0) <= ALU_OUT (3 downto 0);
  end if;
end process;
      
end dataflow;
