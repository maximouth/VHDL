library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Alu is
  port ( op1			: in Std_Logic_Vector(31 downto 0);
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

end Alu;

----------------------------------------------------------------------



architecture DataFlow OF Alu is



  
  
  signal tmp : integer;

  
begin


  
  
  process (cmd_add, cmd_and, cmd_or, cmd_xor)

    function to_integer( s : std_logic ) return natural is
    begin
      if s = '1' then
        return 1;
      else
        return 0;
      end if;
    end function;
    

  begin


    
    -- **** ADD ****
    if (cmd_add = '1') and (cmd_and = '0') and (cmd_or = '0') and (cmd_XOR = '0')  then
      
      tmp <= to_integer (unsigned (op1) + unsigned (op2) + to_integer (cin));

      -- si depassement capacité lever flag V
      if tmp > 16#FFFFFFFF# then
        V <= '1';
        N <= '0';
        Z <= '0';       
        COUT <= '0';         
        res <= Std_Logic_Vector (16#FFFFFFFF# - to_unsigned (tmp, 32) );

      -- si = 0 lever flag N
      else
        if (tmp = 0) then
          V <= '0';
          N <= '0';
          Z <= '1';       
          COUT <= '0';         
          res <= Std_Logic_Vector ( to_unsigned (tmp, 32));

        -- si = 0xFFFFFFFF -> sortie = 0 lever flag N + V
        else
          if (tmp = 16#FFFFFFFF#) then
            V <= '1';
            N <= '0';
            Z <= '1';       
            COUT <= '0';         
            res <= Std_Logic_Vector ( to_unsigned (tmp, 32));


          -- si negatif lever flag Z
          else
            if (tmp = (16#FFFFFFFF#)) then
              V <= '0';
              N <= '1';
              Z <= '0';       
              COUT <= '0';         
              res <= Std_Logic_Vector ( to_unsigned (tmp, 32));
              


            -- sinon ne lever aucun flag
            else        
              res <= Std_Logic_Vector ( to_unsigned (tmp, 32));
              N <= '0';
              Z <= '0';       
              V <= '0';       
              COUT <= '0';         
            --end negatif si lever flag Z
            end if;
          -- end  si = 0xFFFFFFFF
          end if;
        -- end si = 0
        end if;
      --  end depassement capacité
      end if;
    -- end add  
    end if;           

    -- **** AND ****
    if (cmd_add = '0') and (cmd_and = '1') and (cmd_or = '0') and (cmd_XOR = '0')   then
      res <= OP2 and OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
    -- end and  
    end if;    
    
  -- **** OR ****
    if (cmd_add = '0') and (cmd_and = '0') and (cmd_or = '1') and (cmd_XOR = '0')   then
      res <= OP2 or OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
    -- end OR  
    end if;    

      -- **** XOR ****
    if (cmd_add = '0') and (cmd_and = '0') and (cmd_or = '0') and (cmd_XOR = '1')   then
      res <= OP2 xor OP2;
      N <= '0';
      Z <= '0';       
      V <= '0';       
      COUT <= '0';         
    -- end XOR  
    end if;    


  end process;

  
end DataFlow;
----------------------------------------------------------------------
