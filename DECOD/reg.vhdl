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
    -- 0 reset, 1 process the instruction
    reset_n		: in Std_Logic;
    vdd			: in bit;
    vss			: in bit);
end Reg;

architecture Behavior OF Reg is

-- RF 
  type rf_array is array(15 downto 0) of std_logic_vector(31 downto 0);
  signal r_reg	 : rf_array;
  signal r_valid : Std_Logic_Vector(15 downto 0) := X"FFFF";
  signal r_valid_czn : Std_Logic := '1';
  signal r_valid_ovr : Std_Logic := '1';

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

    report "-----**** CK ****------ : " & Std_Logic'image(ck);
    
    report "carry : " & Std_Logic'image(reg_cry);
    report "zero : " & Std_Logic'image(reg_zero);
    report "neg  : " & Std_Logic'image(reg_neg);
    report "cznv : " & Std_Logic'image(reg_cznv);
    report "ovr  : " & Std_Logic'image(reg_ovr);
    report "vv   : " & Std_Logic'image(reg_vv);
    report "PC   : " & integer'image(to_integer(unsigned(r_reg(15))));
    report "PCv  : " & Std_Logic'image(reg_pcv);
    

    report "radr1 : " & Std_Logic'image(radr1(3)) & Std_Logic'image(radr1(2)) & Std_Logic'image(radr1(1)) & Std_Logic'image(radr1(0)) ;
    report "radr2 : " & Std_Logic'image(radr2(3)) & Std_Logic'image(radr2(2)) & Std_Logic'image(radr2(1)) & Std_Logic'image(radr2(0)) ;
    report "radr3 : " & Std_Logic'image(radr3(3)) & Std_Logic'image(radr3(2)) & Std_Logic'image(radr3(1)) & Std_Logic'image(radr3(0)) ;
    

    report "inval_ovr : " & Std_Logic'image(inval_ovr);
    report "inval_czn : " & Std_Logic'image(inval_czn);

    report "inc pc : " & Std_Logic'image(inc_pc);
    
    
    if rising_edge(ck) then
      -- remetre l'etat du registre à 0
      if reset_n = '0' then
        report "RESET";
        r_valid <= X"FFFF";
        r_valid_czn <= '1';
        r_valid_ovr <= '1';
        r_reg(15) <= X"00000000";
        r_reg(14) <= X"00000000";
        r_reg(1)  <= X"00000000";
        r_reg(2)  <= X"00000000";
        r_reg(3)  <= X"00000000";
        r_reg(4)  <= X"00000000";
        r_reg(5)  <= X"00000000";
        r_reg(6)  <= X"00000000";
        r_reg(7)  <= X"00000000";
        r_reg(8)  <= X"00000000";
        r_reg(9)  <= X"00000000";
        r_reg(10)  <= X"00000000";
        r_reg(11)  <= X"00000000";
        r_reg(12)  <= X"00000000";
        r_reg(13)  <= X"00000000";
        --reg_cry	 <= '0';
        --reg_zero       <= '0';
        --reg_neg	 <= '0';
        --reg_ovr	 <= '0';
        --reg_cznv       <= '1';
        --reg_vv	 <= '1';
      else
        
        -- changer la validité du port 1
        if inval1 = '1' then
          --adr_tmp := to_integer ( unsigned (inval_adr1));
          r_valid(to_integer ( unsigned (inval_adr1))) <= '0';
        end if;

        -- changer la validité du port 2
        if inval2 = '1' then
          --adr_tmp := to_integer ( unsigned (inval_adr2));
          r_valid(to_integer ( unsigned (inval_adr2))) <= '0';
        end if;

        -- changer la validité des flags c,z,n
        if inval_czn = '1' then
          r_valid_czn <= '0';
        end if;
        
        -- changer la validité du flag ovr
        if inval_ovr = '1' then
          r_valid_ovr <= '0';
        end if;
        
        -- incrementer pc 
        if inc_pc = '1' then
          report "dans inc_pc";
          if r_valid (15) = '0' then
            r_valid (15) <= '1';
            cpt := to_integer(unsigned(r_reg(15)));
            cpt := cpt + 4;
            r_reg (15) <= Std_Logic_Vector ( to_unsigned (cpt, 32));
          end if;
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
        if (wen2 = '1') and not((wen1 = '1') and (wadr1 = wadr2)) then
          adr_tmp := to_integer ( unsigned (wadr2));
          if r_valid (adr_tmp) = '0' then
            r_valid (adr_tmp) <= '1';
            r_reg (adr_tmp) <= wdata2;
          end if;
          
        end if;


        -- ecriture flags
        if cspr_wb = '1' then

          -- cas flag CNZ
          if r_valid_czn = '0' then
            r_valid_czn <= '1';
          end if;
          
          -- cas flag V
          if r_valid_ovr = '0' then
            r_valid_ovr <= '1';
          end if;
          
        end if;
      end if; -- rising edge
      
    end if;

    report "carry : " & Std_Logic'image(reg_cry);
    report "zero : " & Std_Logic'image(reg_zero);
    report "neg  : " & Std_Logic'image(reg_neg);
    report "cznv : " & Std_Logic'image(reg_cznv);
    report "ovr  : " & Std_Logic'image(reg_ovr);
    report "vv   : " & Std_Logic'image(reg_vv);
    
  end process;

-- read registers ports
  reg_rd1 <= r_reg (to_integer (unsigned (radr1)));
  reg_v1  <= r_valid (to_integer (unsigned (radr1)));

  reg_rd2 <= r_reg (to_integer (unsigned (radr2)));
  reg_v2  <= r_valid (to_integer (unsigned (radr2)));

  reg_rd3 <= r_reg (to_integer (unsigned (radr3)));
  reg_v3  <= r_valid (to_integer (unsigned (radr3)));

  reg_pc  <= r_reg (15);
  reg_pcv <= r_valid (15);

-- read CSPR Port
  reg_cznv <= r_valid_czn;
  reg_cry <= wcry when r_valid_czn = '1';
  reg_zero <= wzero when r_valid_czn = '1';
  reg_neg <= wneg when r_valid_czn = '1';

  reg_vv <= r_valid_ovr;
  reg_ovr <= wovr when r_valid_ovr = '1';
end Behavior;



