library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity mux_tb is
end mux_tb;

architecture Structurel of mux_tb is
  --  Declaration un composant
  component mux
    port (
      input1 : in Std_Logic_Vector (31 downto 0);
      input2 : in Std_Logic_Vector (31 downto 0);

      cmd : in Std_logic ;

      output : out Std_Logic_Vector (31 downto 0)
      );
  end component;    


    signal input1 : Std_Logic_Vector (31 downto 0);
    signal input2 : Std_Logic_Vector (31 downto 0);

    signal cmd : Std_logic;

    signal output : Std_Logic_Vector (31 downto 0);

    
begin
  Mux_0: mux
    port map (
      input1 => input1,
      input2 => input2,
      cmd => cmd,
      output => output
);
      
      process

      begin

        input1 <= "00000000000000000000000000000000";
        input2 <= "11111111111111111111111111111111";
        wait for 1 ns;
        
        cmd <= '1';
        wait for 1 ns;
        
        cmd <= '0';
        wait for 1 ns;

        cmd <= '1';
        wait for 1 ns;

--  Wait forever; this will finish the simulation.
        wait;
      end process;
    end Structurel;

