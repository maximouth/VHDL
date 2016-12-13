library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unknown_tb is
end unknown_tb;

architecture Structurel of unknown_tb is
  --  Declaration un composant
  component unknown
    port (

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
  end component;    

  --declaration signaux
  signal inputLB : Std_Logic;
  signal inputLW : Std_Logic;
  signal inputSB : Std_Logic;
  signal inputSW : Std_Logic;
  
  signal inputDATA : Std_Logic_Vector (31 downto 0);
  signal inputDEST : Std_Logic_Vector (3  downto 0);

  signal inputMUX3 : Std_Logic_Vector (31 downto 0);

  signal D2E_empty : Std_Logic;
  signal D2E_pop : Std_Logic;

  signal fifo_din : Std_Logic_Vector (71 downto 0);

  signal fifo_full : Std_Logic;
  signal fifo_push: Std_Logic;
  signal ck : Std_Logic; 

  
begin
--instanciation composant 
  UNK_0: unknown
    port map (
      inputLW => inputLW,
      inputLB => inputLB,
      inputSW => inputSW,
      inputSB => inputSB,

      inputDATA => inputDATA,
      inputDEST => inputDEST,
      inputMUX3 => inputMUX3,

      D2E_empty => D2E_empty,
      D2E_pop => D2E_pop,

      fifo_din => fifo_din,

      fifo_full => fifo_full,
      fifo_push => fifo_push,

      ck => ck
      
      );

  -- debut test
      process

      begin

        inputLW <= '0';
        inputLB <= '1';
        inputSW <= '0';
        inputSB <= '0';
        
        inputDATA <= "11111111111111111111111111111111";
        inputMUX3 <= "00000000000000000000000000000000";
        inputDEST <=  "0101";

        D2E_empty <= '0';
        fifo_full <= '0';
        ck <= '0';
        wait for 1 ns;
        ck <= '1';      
        wait for 1 ns;

        D2E_empty <= '1';
        fifo_full <= '0';
        ck <= '0';
        wait for 1 ns;
        ck <= '1';      
        wait for 1 ns;

        D2E_empty <= '0';
        fifo_full <= '1';
        ck <= '0';
        wait for 1 ns;
        ck <= '1';      
        wait for 1 ns;

        D2E_empty <= '0';
        fifo_full <= '0';
        ck <= '0';
        wait for 1 ns;
        ck <= '1';      
        wait for 1 ns;

        
--  Wait forever; this will finish the simulation.
        wait;
      end process;
    end Structurel;



