library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity reg_tb is
end reg_tb;

architecture Structurel of reg_tb is
  --  Declaration un composant
  component reg
    port (
      -- Write Port 1 prioritaire
      wdata1		: in Std_Logic_Vector(31 downto 0);
      wadr1		: in Std_Logic_Vector(3 downto 0);
      wen1		: in Std_Logic;

      -- Write Port 2 non prioritaire
      wdata2		: in Std_Logic_Vector(31 downto 0);
      wadr2		: in Std_Logic_Vector(3 downto 0);
      wen2		: in Std_Logic;

      -- Write CSPR Port
      wcry		: in Std_Logic;
      wzero		: in Std_Logic;
      wneg		: in Std_Logic;
      wovr		: in Std_Logic;
      cspr_wb		: in Std_Logic;
      
      -- Read Port 1 32 bits
      reg_rd1		: out Std_Logic_Vector(31 downto 0);
      radr1		: in Std_Logic_Vector(3 downto 0);
      reg_v1		: out Std_Logic;

      -- Read Port 2 32 bits
      reg_rd2		: out Std_Logic_Vector(31 downto 0);
      radr2		: in Std_Logic_Vector(3 downto 0);
      reg_v2		: out Std_Logic;

      -- Read Port 3 32 bits
      reg_rd3		: out Std_Logic_Vector(31 downto 0);
      radr3		: in Std_Logic_Vector(3 downto 0);
      reg_v3		: out Std_Logic;

      -- Read Port 4 32 bits
      reg_rd4		: out Std_Logic_Vector(31 downto 0);
      radr4		: in Std_Logic_Vector(3 downto 0);
      reg_v4		: out Std_Logic;
      
      -- read CSPR Port
      reg_cry		: out Std_Logic;
      reg_zero		: out Std_Logic;
      reg_neg		: out Std_Logic;
      reg_cznv		: out Std_Logic;
      reg_ovr		: out Std_Logic;
      reg_vv		: out Std_Logic;
      
      -- Invalidate Port 
      inval_adr1	        : in Std_Logic_Vector(3 downto 0);
      inval1		: in Std_Logic;

      inval_adr2	        : in Std_Logic_Vector(3 downto 0);
      inval2		: in Std_Logic;

      inval_czn	        : in Std_Logic;
      inval_ovr	        : in Std_Logic;

      -- PC
      reg_pc		: out Std_Logic_Vector(31 downto 0);
      reg_pcv		: out Std_Logic;
      inc_pc		: in Std_Logic;
      
      -- global interface
      ck		: in Std_Logic;
      -- 0 faire reset 1 ne pas le faire
      reset_n		: in Std_Logic;
      vdd		: in bit;
      vss		: in bit
    );
  end component;    

  

  -- SIGNAL Write Port 1 prioritaire
  signal wdata1		:  Std_Logic_Vector(31 downto 0);
  signal wadr1		:  Std_Logic_Vector(3 downto 0);
  signal wen1		:  Std_Logic;

  -- SIGNAL Write Port 2 non prioritaire
  signal wdata2		:  Std_Logic_Vector(31 downto 0);
  signal wadr2		:  Std_Logic_Vector(3 downto 0);
  signal wen2		:  Std_Logic;

  -- SIGNAL Write CSPR Port
  signal wcry		:  Std_Logic;
  signal wzero		:  Std_Logic;
  signal wneg		:  Std_Logic;
  signal wovr		:  Std_Logic;
  signal cspr_wb	:  Std_Logic;
  
  -- Read Posignal rt 1 32 bits
  signal reg_rd1	:  std_logic_vector(31 downto 0);
  signal radr1		:  std_logic_vector(3 downto 0);
  signal reg_v1		:  Std_Logic;

  -- SIGNAL Read Posignal rt 2 32 bits
  signal reg_rd2		:  std_logic_vector(31 downto 0);
  signal radr2		:  std_logic_vector(3 downto 0);
  signal reg_v2		:  Std_Logic;

  -- SIGNAL Read Posignal rt 3 32 bits
  signal reg_rd3		:  std_logic_vector(31 downto 0);
  signal radr3		:  std_logic_vector(3 downto 0);
  signal reg_v3		:  Std_Logic;

  -- SIGNAL Read Posignal rt 4 32 bits
  signal reg_rd4	:  std_logic_vector(31 downto 0);
  signal radr4		:  std_logic_vector(3 downto 0);
  signal reg_v4		:  Std_Logic;

  
  -- signal read CSPR Port
  signal reg_cry		:  Std_Logic;
  signal reg_zero		:  Std_Logic;
  signal reg_neg		:  Std_Logic;
  signal reg_cznv		:  Std_Logic;
  signal reg_ovr		:  Std_Logic;
  signal reg_vv		:  Std_Logic;
  
  -- validate Port 
  signal inval_adr1	        :  Std_Logic_Vector(3 downto 0);
  signal inval1		:  Std_Logic;

  signal inval_adr2	        :  Std_Logic_Vector(3 downto 0);
  signal inval2		:  Std_Logic;

  signal inval_czn	        :  Std_Logic;
  signal inval_ovr	        :  Std_Logic;

  -- PC
  signal reg_pc	:  Std_Logic_Vector(31 downto 0);
  signal reg_pcv	:  Std_Logic;
  signal inc_pc		:  Std_Logic;
  
  -- global tesignal rface
  signal ck			:  Std_Logic;
  -- 0 faisignal re signal reset 1 ne pas le faisignal re
  signal reset_n	:  Std_Logic;
  signal vdd			:  bit;
  signal vss			:  bit;


begin
  reg_0 : reg
    port map (
 -- Write Port 1 prioritaire
      wdata1 => wdata1,
      wadr1  => wadr1,
      wen1   => wen1,

      -- Write Port 2 non prioritaire
      wdata2 =>wdata2,
      wadr2  =>wadr2,
      wen2   =>wen2,

      -- Write CSPR Port
      wcry    =>wcry,
      wzero   =>wzero,
      wneg    =>wneg,
      wovr    =>wovr,
      cspr_wb =>cspr_wb,
      
      -- Read Port 1 32 bits
      reg_rd1 =>reg_rd1,
      radr1   =>radr1,
      reg_v1  =>reg_v1,

      -- Read Port 2 32 bits
      reg_rd2 =>reg_rd2,
      radr2   =>radr2,
      reg_v2  =>reg_v2,

      -- Read Port 3 32 bits
      reg_rd3 =>reg_rd3,
      radr3   =>radr3,
      reg_v3  => reg_v3,

      -- Read Port 4 32 bits
      reg_rd4 =>reg_rd4,
      radr4   =>radr4,
      reg_v4  => reg_v4,
      
      -- read CSPR Port
      reg_cry  => reg_cry,
      reg_zero => reg_zero,
      reg_neg  => reg_neg,
      reg_cznv => reg_cznv,
      reg_ovr  => reg_ovr,
      reg_vv   => reg_vv,
      
      -- Invalidate Port 
      inval_adr1 => inval_adr1,
      inval1     => inval1,

      inval_adr2 => inval_adr2,
      inval2     => inval2,

      inval_czn => inval_czn,
      inval_ovr	=> inval_ovr,

      -- PC
      reg_pc  => reg_pc,
      reg_pcv => reg_pcv,	
      inc_pc  => inc_pc,	
      
      -- global interface
      ck => ck,
      -- 0 faire reset 1 ne pas le faire
      reset_n => reset_n,	
      vdd     => vdd,
      vss     => vss	


  );

  process

  begin




    -- reset le banc de registre

    radr1 <= "0000";
    radr2 <= "0000";        
    radr3 <= "0000";

    
    reset_n <= '0';
    inc_pc <= '1';
    
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;
    
    reset_n <= '1';

    cspr_wb   <= '1';
    inval_czn <= '0';
    inval_ovr <= '0';

    wcry  <= '1';
    wzero <= '1';
    wneg  <= '1';
    wovr  <= '1';
    
    -- invalider r1
    inval_adr1 <= "0001";
    inval1 <= '1';

    radr1 <= "0001";
    
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;        

    inval_czn <= '1';
    inval_ovr <= '1';
    
    inval1 <= '0';

    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;

    cspr_wb   <= '0';
    wcry  <= '0';
    wzero <= '0';
    wneg  <= '0';
    wovr  <= '0';


    
    -- ecrire dans r1
    wdata1 <= "11111111111111110000000000000000";
    wadr1 <= "0001";
    wen1 <= '1';
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;
    
    -- lire dans r1
    radr1 <= "0001";
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;
    
    -- ecrire dans r1
    wdata1 <= "00000000000000001111111111111111";
    wadr1 <= "0001";
    wen1 <= '1';
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;
    
    --lire dans r1 la meme valeur que dans la premiere ecriture 
    radr1 <= "0001";
    ck <= '0';
    wait for 1 ns;
    ck <= '1';
    wait for 1 ns;

    
    --  Wait forever; this will finish the simulation.    
    wait;
  end process;
end Structurel;
