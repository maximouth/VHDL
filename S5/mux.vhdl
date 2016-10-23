library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux is
  port (
      input1 : in Std_Logic_Vector (31 downto 0);
      input2 : in Std_Logic_Vector (31 downto 0);

      cmd : in Std_logic ;

      output : out Std_Logic_Vector (31 downto 0)

    );

end Mux;


architecture DataFlow OF Mux is

begin
  process (cmd)
    begin
      if cmd = '0'
      then
        output <= input1;
      else
        output <= input2;  
      end if;  

    end process;
  end DataFlow;
