library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity addaccu_tb is
end addaccu_tb;

architecture Structurel of addaccu_tb is
	--  Declaration un composant
	component addaccu
	port (          A, B :in std_logic_vector (3 downto 0);
			CLK, SEL : in std_logic;
			S : out std_logic_vector (3 downto 0) );

	end component;

	signal A, B, S : std_logic_vector (3 downto 0);
        signal CLK, SEL : std_logic;
        

	begin
	addaccu_0: addaccu
	port map (	A => A,
			B => B,
			CLK => CLK,
                        SEL => SEL,
			S => S);

process

begin

--reset the alu
  A <= "0000";
  B <= "0000";  
  SEL <= '0';
  CLK <= '0';
  wait for 1 ns;      
  CLK <= '1';
  wait for 1 ns;
  
-- add 5 to the value in ACCU
La : for t in 0 to 50 loop
  A <= "0000";
  B <= "0101";  

  if CLK = '0' then
    CLK <= '1';
  else
    CLK <= '0';
    
  end if;

  SEL <= '1';             
  
  wait for 1 ns;    
end loop;  -- t 

--  Wait forever; this will finish the simulation.
wait;
end process;
end Structurel;
