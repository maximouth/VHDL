library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Reg is
  port(
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
    ck			: in Std_Logic;
    -- 0 faire reset 1 ne pas le faire
    reset_n		: in Std_Logic;
    vdd			: in bit;
    vss			: in bit);
end Reg;

architecture Behavior OF Reg is

-- RF 
  type rf_array is array(15 downto 0) of std_logic_vector(31 downto 0);
  signal r_reg	: rf_array;

  signal r_valid        : Std_Logic_Vector(15 downto 0);
  signal r_c		: Std_Logic;
  signal r_z		: Std_Logic;
  signal r_n		: Std_Logic;
  signal r_v		: Std_Logic;
  signal r_cznv	        : Std_Logic;
  signal r_vv		: Std_Logic;

begin

  process (ck)

    -- *** convertir de Std_Logic_Vector vers integer :
    -- variable toto : integer := to_integer ( unsigned (r_valid) );

    -- *** convertir de integer vers Std_Logic_Vector :
    -- r_valid <= Std_Logic_Vector ( to_unsigned (10, 4));

    -- surement mettre le contenu de pc dans le compteur? 
    variable cpt : integer := 0;
    variable adr_tmp : integer := 0;
    
  begin

    if rising_edge(ck) then
      -- remetre l'etat du registre à 0
      if reset_n = '0' then
        r_valid <= X"FFFF";
        r_reg(15) <= X"00000000";
        r_reg(14) <= X"00000000";
        r_reg(1)  <= X"00000000";        
        r_cznv	<= '1';
        r_vv	<= '1';
      end if;

      -- incrementer pc 
      if inc_pc = '1' then
        cpt := cpt + 4;
        r_reg (14) <= Std_Logic_Vector (to_signed ( cpt , 32));
      end if;       

      -- changer la validité du port 1
      if inval1 = '1' then
        adr_tmp := to_integer ( unsigned (inval_adr1));
        r_valid(adr_tmp) <= '0';
      end if;

      -- changer la validité du port 2
      if inval2 = '1' then
        adr_tmp := to_integer ( unsigned (inval_adr2));
        r_valid(adr_tmp) <= '0';
      end if;

      -- ecriture port 1
      if (wen1 = '1') then
        adr_tmp := to_integer ( unsigned (wadr1));
        if r_valid (adr_tmp) = '0' then
          r_valid (adr_tmp) <= '1';
          r_reg (adr_tmp) <= wdata1;
        end if;
        
      end if;
      
      -- ecriture port 2
      if (wen2 = '1') then
        adr_tmp := to_integer ( unsigned (wadr2));
        if r_valid (adr_tmp) = '0' then
          r_valid (adr_tmp) <= '1';
          r_reg (adr_tmp) <= wdata2;
        end if;
        
      end if;


      -- ecriture flags
      if cspr_wb = '1' then

        -- cas flag CNZ
        if inval_czn = '1' then
          r_c <= wcry;
          r_z <= wzero;
          r_n <= wneg;
        end if;
        
        -- cas flag V
        if inval_ovr = '1' then
          r_v <= wovr;
        end if;
        
      end if;
    end if; -- rising edge
    
    -- lecture port 1
    
    adr_tmp := to_integer (unsigned (radr1));
    reg_rd1 <= r_reg (adr_tmp);
    reg_v1  <= r_valid (1);
    
    -- lecture port 2
    adr_tmp := to_integer ( unsigned (radr2));
    reg_rd2 <= r_reg (adr_tmp);
    reg_v2  <= r_valid (adr_tmp);

    -- lecture port
    adr_tmp := to_integer ( unsigned (radr3));
    reg_rd3 <= r_reg (adr_tmp);
    reg_v3  <= r_valid (adr_tmp);

    --lecture cspr
    reg_cry  <= r_c;
    reg_zero <= r_z;
    reg_neg  <= r_n;
    reg_cznv <= r_cznv;
    reg_ovr  <= r_v;
    reg_vv <= r_vv;

    -- lecture pc
    reg_pc  <= r_reg (14);
    reg_pcv <= r_valid (14);
    

  end process;

-- read registers ports

-- read CSPR Port

end Behavior;



