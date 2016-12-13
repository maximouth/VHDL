library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unknown is
  port(

    inputLW : in Std_logic;
    inputLB : in Std_logic;
    inputSW : in Std_logic;
    inputSB : in Std_logic;
    
    inputDATA : in Std_Logic_Vector (31 downto 0);
    inputDEST : in Std_Logic_Vector (3 downto 0);

    inputMUX3 : in Std_Logic_Vector (31 downto 0);
    
    D2E_empty : in Std_Logic;
    D2E_pop : out Std_Logic ;

    fifo_din : out Std_Logic_Vector ( 71 downto 0);

    fifo_full : in Std_Logic ;  
    fifo_push: out Std_logic ;
    ck : in Std_logic
    
    );
end unknown;



architecture Behavior OF unknown is
  
--declaration composant externe
  
  begin

--instanciation composant externe
    process (ck)
      begin
      if fifo_full = '1' or D2E_empty = '1' then
        fifo_push <= '0';
        fifo_din <= Std_Logic_Vector ( to_unsigned (0, 72));
        D2E_pop <= '0';

      else
        if fifo_full = '0' and D2E_empty = '0' then
        fifo_push <= '1';
        fifo_din <= inputLB & inputLW & inputSB & inputSW &
                    inputDATA & inputDEST & inputMUX3;
        D2E_pop <= '1';
        end if;
      end if;
    end process;
    
  end Behavior;
