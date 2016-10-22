library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity alu_tb is
end alu_tb;

architecture Structurel of alu_tb is
  --  Declaration un composant
  component alu

    port (
      op1			: in Std_Logic_Vector(31 downto 0);
      op2			: in Std_Logic_Vector(31 downto 0);
      cin			: in Std_Logic;

      cmd_add	: in Std_Logic;
      cmd_and	: in Std_Logic;
      cmd_or		: in Std_Logic;
      cmd_xor	: in Std_Logic;

      res			: out Std_Logic_Vector(31 downto 0);
      cout		: out Std_Logic;
      z			: out Std_Logic;
      n			: out Std_Logic;
      v			: out Std_Logic;
      
      vdd			: in bit;
      vss			: in bit);


    
  end component;

  signal op1, op2, res : Std_Logic_Vector (31 downto 0);
  signal cmd_add, cmd_and, cmd_or, cmd_xor, cin, cout, z, n, v : Std_Logic;     
  signal vdd, vss : bit;

  
begin
  alu_0: alu
    port map (
      op1 => op1,
      op2 => op2,
      cmd_add => cmd_add,
      cmd_and => cmd_and,
      cmd_or  => cmd_or,
      cmd_xor => cmd_xor,
      cin => cin,
      cout => cout,       
      vss => vss,
      vdd => vdd,
      z => z,
      n => n,
      v => v,
      res => res
      );
  
  process

  begin

--reset the alu
    cmd_xor <= '0';
    cmd_or <= '0';
    cmd_and <= '0';
    cmd_add <= '0';
    vss <= '1';
    vdd <= '0';
    cin <= '0';
    wait for 1 ns;

    --xor
    cmd_add <= '1';  
    op1 <= "00000000000000000000000000000101";      
    op2 <= "00000000000000000000000000000001";      
    wait for 1 ns;

    cmd_add <= '0';  
    wait for 1 ns;

    -- or
    cmd_add <= '1';  
    op1 <= "00000000000000000000000000000001";      
    op2 <= "00000000000000000000000000000001";      
    wait for 1 ns;

    cmd_add <= '0';  
    wait for 1 ns;

   --or
    cmd_add <= '1';  
    op1 <= "00000000000000000000000000000101";      
    op2 <= "00000000000000000000000000000001";      
    wait for 1 ns;

    cmd_add <= '0';  
    wait for 1 ns;

    
    -- or
    cmd_add <= '1';  
    op1 <= "00000000000000000000000000000001";      
    op2 <= "11111111111111111111111111111111";      
    wait for 1 ns;

    cmd_add <= '0';  
    wait for 1 ns;

    -- or
    cmd_add <= '1';  
    op1 <= "01010101010101010101010101010101";      
    op2 <= "10101010101010101010101010101010";      
    wait for 1 ns;

    cmd_add <= '0';  
    wait for 1 ns;

    

    
--  Wait forever; this will finish the simulation.
    wait;
  end process;
end Structurel;
