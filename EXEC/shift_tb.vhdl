library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity shift_tb is
end shift_tb;

architecture Structurel of shift_tb is
  --  Declaration un composant
  component shift
    port (
    op1 : in Std_Logic_Vector (31 downto 0);
    
    dec_cy		: in Std_Logic;
    dec_shift_lsl	: in Std_Logic;
    dec_shift_lsr	: in Std_Logic;
    dec_shift_asr	: in Std_Logic;
    dec_shift_ror	: in Std_Logic;
    dec_shift_rrx	: in Std_Logic;
    dec_shift_val	: in Std_Logic_Vector(4 downto 0);

    shift_cy: in Std_logic ;
    shift_cy_out: out Std_logic ;
    shift_output : out Std_Logic_Vector (31 downto 0)

  --end shift
);

  end component;    


-- declaration des signaux
  signal op1 : Std_Logic_Vector (31 downto 0);
  signal dec_shift_val : Std_Logic_Vector (4 downto 0);      
  
  signal dec_shift_lsl : Std_logic;
  signal dec_shift_lsr : Std_logic;
  signal dec_shift_asr : Std_logic;
  signal dec_shift_ror : Std_logic;
  signal dec_shift_rrx : Std_logic;

  signal cy1 : std_logic;
  signal cy2 : std_logic;
  
  signal shift_output : Std_Logic_Vector (31 downto 0);

begin

  -- composant 1
  shift_0: shift
    port map (
      op1 => op1,
      dec_shift_lsl => dec_shift_lsl,
      dec_shift_lsr => dec_shift_lsr,
      dec_shift_asr => dec_shift_asr,
      dec_shift_ror => dec_shift_ror,
      dec_shift_rrx => dec_shift_rrx,

      dec_cy => cy1,
      shift_cy => cy2,

      dec_shift_val => dec_shift_val,
      shift_output => shift_output



      );


--ce qu'il ce passe
  process
  begin
    dec_shift_lsl <= '0';
    dec_shift_lsr <= '0';
    dec_shift_asr <= '0';
    dec_shift_ror <= '1';
    dec_shift_rrx <= '0';   

    op1 <= "10000000000000000000000000000100";
    dec_shift_val <= "00000";

    wait for 1 ns;
    dec_shift_val <= "00001";

    wait for 1 ns;
    dec_shift_val <= "00010";
    
    wait for 1 ns;
    dec_shift_val <= "00011";

    wait for 1 ns;
    dec_shift_val <= "00100";
    
    wait for 1 ns;
    dec_shift_val <= "00101";

    wait;
  end process;
end Structurel;

