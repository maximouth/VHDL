library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Alu is
  port ( op1		: in Std_Logic_Vector(31 downto 0);
         op2		: in Std_Logic_Vector(31 downto 0);
         cin		: in Std_Logic;

         cmd_add	: in Std_Logic;
         cmd_and	: in Std_Logic;
         cmd_or		: in Std_Logic;
         cmd_xor	: in Std_Logic;

         res		: out Std_Logic_Vector(31 downto 0);
         cout		: out Std_Logic;
         z		: out Std_Logic;
         n		: out Std_Logic;
         v		: out Std_Logic;
         
         vdd		: in bit;
         vss		: in bit);

end Alu;

----------------------------------------------------------------------



architecture DataFlow OF Alu is


begin
  
  process (cmd_add, cmd_and, cmd_or, cmd_xor, op1, op2, cin)

    variable tmp : Std_Logic_Vector (31 downto 0) ;
    variable car : std_logic;

  begin
    
    -- **** ADD ****
    if (cmd_add = '1') and (cmd_and = '0') and (cmd_or = '0') and (cmd_XOR = '0')  then

      --calculer le premier bit avec cin
      tmp(0) :=  op1(0) xor op2(0) xor cin;
      car := ( cin and (op1(0) xor op2(0))) or (op1(0) and op2(0)) ;

      --calculer tout les bits
      Calc : for i in 1 to 31 loop
        tmp (i) := op1(i) xor op2(i) xor car;
        car := ( car  and (op1(i) xor op2(i))) or (op1(i) and op2(i)) ;
      end loop Calc;  -- i in 1 to 31
      
      
      COUT <= car;
      res <= tmp ;
      
      -- si depassement capacité lever flag V
      if (car = '1')then
        V <= '1';
        N <= '0';
        Z <= '0';       
      end if;
      
      -- si = 0 lever flag N
      
      if (tmp = "00000000000000000000000000000000") then
        V <= '0';
        N <= '0';
        Z <= '1';       
      end if;          

     -- si negatif lever flag Z
      if (tmp (31) = '1') then 
        V <= '0';
        N <= '1';
        Z <= '0';       
      end if;
      
      -- sinon ne lever aucun flag
    else
      N <= '0';
      Z <= '0';       
      V <= '0';       


      
-- end add  
    end if;           

    -- **** AND ****
    if (cmd_add = '0') and (cmd_and = '1') and (cmd_or = '0') and (cmd_XOR = '0')   then
      res <= OP1 and OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
      -- end and  
    end if;    
    
    -- **** OR ****
    if (cmd_add = '0') and (cmd_and = '0') and (cmd_or = '1') and (cmd_XOR = '0')   then
      res <= OP1 or OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
      -- end OR  
    end if;    

    -- **** XOR ****
    if (cmd_add = '0') and (cmd_and = '0') and (cmd_or = '0') and (cmd_XOR = '1')   then
      res <= OP1 xor OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
      -- end XOR  
    end if;    


  end process;

  
end DataFlow;
----------------------------------------------------------------------
