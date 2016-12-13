library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- declaration du shifter
entity shift is
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

end shift;

--facon dont marche le shift
architecture DataFlow OF shift is

  begin
    process (dec_shift_val, dec_shift_lsl, dec_shift_lsr, dec_shift_asr,
             dec_shift_ror, dec_shift_rrx, op1, dec_cy) 
    begin  
      
    -- decalage logique gauche
    if (dec_shift_lsl = '1') and (dec_shift_lsr = '0') and (dec_shift_asr = '0')
       and (dec_shift_ror = '0') and (dec_shift_rrx = '0')
    then
      case dec_shift_val is

        when "00000" =>
          shift_output <= op1;
          shift_cy_out <= '0';
        when "00001" =>
          shift_output(31 downto 1) <= op1 (30 downto 0);
          shift_output(0) <= '0'; 
          shift_cy_out <= op1 (31);
        when "00010" =>
          shift_output(31 downto 2) <= op1 (29 downto 0);
          shift_output(1 downto 0) <= "00"; 
          shift_cy_out <= op1 (30);
        when "00011" =>
          shift_output(31 downto 3) <= op1 (28 downto 0);
          shift_output(2 downto 0) <= "000";
          shift_cy_out <= op1 (29);
        when "00100" =>
          shift_output(31 downto 4) <= op1 (27 downto 0);
          shift_output(3 downto 0) <= "0000"; 
          shift_cy_out <= op1 (28);
        when "00101" =>
          shift_output(31 downto 5) <= op1 (26 downto 0);
          shift_output(4 downto 0) <= "00000"; 
          shift_cy_out <= op1 (27);
        when "00110" =>
          shift_output(31 downto 6) <= op1 (25 downto 0);
          shift_output(5 downto 0) <= "000000"; 
          shift_cy_out <= op1 (26);
        when "00111" =>
          shift_output(31 downto 7) <= op1 (24 downto 0);
          shift_output(6 downto 0) <= "0000000"; 
          shift_cy_out <= op1 (25);
        when "01000" =>
          shift_output(31 downto 8) <= op1 (23 downto 0);
          shift_output(7 downto 0) <= "00000000"; 
          shift_cy_out <= op1 (24);
        when "01001" =>
          shift_output(31 downto 9) <= op1 (22 downto 0);
          shift_output(8 downto 0) <= "000000000"; 
          shift_cy_out <= op1 (23);
        when "01010" =>
          shift_output(31 downto 10) <= op1 (21 downto 0);
          shift_output(9 downto 0) <=  "0000000000"; 
          shift_cy_out <= op1 (22);
        when "01011" =>
          shift_output(31 downto 11) <= op1 (20 downto 0);
          shift_output(10 downto 0) <= "00000000000"; 
          shift_cy_out <= op1 (21);
        when "01100" =>
          shift_output(31 downto 12) <= op1 (19 downto 0);
          shift_output(11 downto 0) <= "000000000000"; 
          shift_cy_out <= op1 (20);
        when "01101" =>
          shift_output(31 downto 13) <= op1 (18 downto 0);
          shift_output(12 downto 0) <= "0000000000000"; 
          shift_cy_out <= op1 (19);
        when "01110" =>
          shift_output(31 downto 14) <= op1 (17 downto 0);
          shift_output(13 downto 0) <= "00000000000000"; 
          shift_cy_out <= op1 (18);
        when "01111" =>
          shift_output(31 downto 15) <= op1 (16 downto 0);
          shift_output(14 downto 0) <= "000000000000000"; 
          shift_cy_out <= op1 (17);
        when "10000" =>
          shift_output(31 downto 16) <= op1 (15 downto 0);
          shift_output(15 downto 0) <= "0000000000000000"; 
          shift_cy_out <= op1 (16);
        when "10001" =>
          shift_output(31 downto 17) <= op1 (14 downto 0);
          shift_output(16 downto 0) <= "00000000000000000"; 
          shift_cy_out <= op1 (15);
        when "10010" =>
          shift_output(31 downto 18) <= op1 (13 downto 0);
          shift_output(17 downto 0) <= "000000000000000000"; 
          shift_cy_out <= op1 (14);
        when "10011" =>
          shift_output(31 downto 19) <= op1 (12 downto 0);
          shift_output(18 downto 0) <= "0000000000000000000"; 
          shift_cy_out <= op1 (13);
        when "10100" =>
          shift_output(31 downto 20) <= op1 (11 downto 0);
          shift_output(19 downto 0) <= "00000000000000000000"; 
          shift_cy_out <= op1 (12);
        when "10101" =>
          shift_output(31 downto 21) <= op1 (10 downto 0);
          shift_output(20 downto 0) <= "000000000000000000000"; 
          shift_cy_out <= op1 (11);
        when "10110" =>
          shift_output(31 downto 22) <= op1 (9 downto 0);
          shift_output(21 downto 0) <= "0000000000000000000000"; 
          shift_cy_out <= op1 (10);
        when "10111" =>
          shift_output(31 downto 23) <= op1 (8 downto 0);
          shift_output(22 downto 0) <= "00000000000000000000000"; 
          shift_cy_out <= op1 (9);
        when "11000" =>
          shift_output(31 downto 24) <= op1 (7 downto 0);
          shift_output(23 downto 0) <= "000000000000000000000000"; 
          shift_cy_out <= op1 (8);
        when "11001" =>
          shift_output(31 downto 25) <= op1 (6 downto 0);
          shift_output(24 downto 0) <= "0000000000000000000000000"; 
          shift_cy_out <= op1 (7);
        when "11010" =>
          shift_output(31 downto 26) <= op1 (5 downto 0);
          shift_output(25 downto 0) <= "00000000000000000000000000"; 
          shift_cy_out <= op1 (6);
        when "11011" =>
          shift_output(31 downto 27) <= op1 (4 downto 0);
          shift_output(26 downto 0) <= "000000000000000000000000000"; 
          shift_cy_out <= op1 (5);
        when "11100" =>
          shift_output(31 downto 28) <= op1 (3 downto 0);
          shift_output(27 downto 0) <= "0000000000000000000000000000"; 
          shift_cy_out <= op1 (4);
        when "11101" =>
          shift_output(31 downto 29) <= op1 (2 downto 0);
          shift_output(28 downto 0) <= "00000000000000000000000000000"; 
          shift_cy_out <= op1 (3);
        when "11110" =>
          shift_output(31 downto 30) <= op1 (1 downto 0);
          shift_output(29 downto 0) <= "000000000000000000000000000000"; 
          shift_cy_out <= op1 (2);
        when "11111" =>
          shift_output(31) <= op1 (0);
          shift_output(30 downto 0) <= "0000000000000000000000000000000"; 
          shift_cy_out <= op1 (1);
        when others => shift_output <= op1 ;
      end case;
      
      --fin lsl
    end if;


    

    -- decalage logique droit
    if (dec_shift_lsl = '0') and (dec_shift_lsr = '1') and (dec_shift_asr = '0')
       and (dec_shift_ror = '0') and (dec_shift_rrx = '0')
    then
      case dec_shift_val is

        when "00000" =>
          shift_output <= op1;
          shift_cy_out <= '0';
        when "00001" =>
          shift_output(30 downto 0) <= op1 (31 downto 1);
          shift_output(31) <= '0'; 
          shift_cy_out <= op1 (0);
        when "00010" =>
          shift_output(29 downto 0) <= op1 (31 downto 2);
          shift_output(31 downto 30) <= "00"; 
          shift_cy_out <= op1 (1);
        when "00011" =>
          shift_output(28 downto 0) <= op1 (31 downto 3);
          shift_output(31 downto 29) <= "000";
          shift_cy_out <= op1 (2);
        when "00100" =>
          shift_output(27 downto 0) <= op1 (31 downto 4);
          shift_output(31 downto 28) <= "0000"; 
          shift_cy_out <= op1 (3);
        when "00101" =>
          shift_output(26 downto 0) <= op1 (31 downto 5);
          shift_output(31 downto 27) <= "00000"; 
          shift_cy_out <= op1 (4);
        when "00110" =>
          shift_output(25 downto 0) <= op1 (31 downto 6);
          shift_output(31 downto 26) <= "000000"; 
          shift_cy_out <= op1 (5);
        when "00111" =>
          shift_output(24 downto 0) <= op1 (31 downto 7);
          shift_output(31 downto 25) <= "0000000"; 
          shift_cy_out <= op1 (6);
        when "01000" =>
          shift_output(23 downto 0) <= op1 (31 downto 8);
          shift_output(31 downto 24) <= "00000000"; 
          shift_cy_out <= op1 (7);
        when "01001" =>
          shift_output(22 downto 0) <= op1 (31 downto 9);
          shift_output(31 downto 23) <= "000000000"; 
          shift_cy_out <= op1 (8);
        when "01010" =>
          shift_output(21 downto 0) <= op1 (31 downto 10);
          shift_output(31 downto 22) <=  "0000000000"; 
          shift_cy_out <= op1 (9);
        when "01011" =>
          shift_output(20 downto 0) <= op1 (31 downto 11);
          shift_output(31 downto 21) <= "00000000000"; 
          shift_cy_out <= op1 (10);
        when "01100" =>
          shift_output(19 downto 0) <= op1 (31 downto 12);
          shift_output(31 downto 20) <= "000000000000"; 
          shift_cy_out <= op1 (11);
        when "01101" =>
          shift_output(18 downto 0) <= op1 (31 downto 13);
          shift_output(31 downto 19) <= "0000000000000"; 
          shift_cy_out <= op1 (12);
        when "01110" =>
          shift_output(17 downto 0) <= op1 (31 downto 14);
          shift_output(31 downto 18) <= "00000000000000"; 
          shift_cy_out <= op1 (13);
        when "01111" =>
          shift_output(16 downto 0) <= op1 (31 downto 15);
          shift_output(31 downto 17) <= "000000000000000"; 
          shift_cy_out <= op1 (14);
        when "10000" =>
          shift_output(15 downto 0) <= op1 (31 downto 16);
          shift_output(31 downto 16) <= "0000000000000000"; 
          shift_cy_out <= op1 (15);
        when "10001" =>
          shift_output(14 downto 0) <= op1 (31 downto 17);
          shift_output(31 downto 15) <= "00000000000000000"; 
          shift_cy_out <= op1 (16);
        when "10010" =>
          shift_output(13 downto 0) <= op1 (31 downto 18);
          shift_output(31 downto 14) <= "000000000000000000"; 
          shift_cy_out <= op1 (17);
        when "10011" =>
          shift_output(12 downto 0) <= op1 (31 downto 19);
          shift_output(31 downto 13) <= "0000000000000000000"; 
          shift_cy_out <= op1 (18);
        when "10100" =>
          shift_output(11 downto 0) <= op1 (31 downto 20);
          shift_output(31 downto 12) <= "00000000000000000000"; 
          shift_cy_out <= op1 (19);
        when "10101" =>
          shift_output(10 downto 0) <= op1 (31 downto 21);
          shift_output(31 downto 11) <= "000000000000000000000"; 
          shift_cy_out <= op1 (20);
        when "10110" =>
          shift_output(9 downto 0) <=  op1 (31 downto 22);
          shift_output(31 downto 10) <= "0000000000000000000000"; 
          shift_cy_out <= op1 (21);
        when "10111" =>
          shift_output(8 downto 0) <= op1 (31 downto 23);
          shift_output(31 downto 9) <= "00000000000000000000000"; 
          shift_cy_out <= op1 (22);
        when "11000" =>
          shift_output(7 downto 0) <= op1 (31 downto 24);
          shift_output(31 downto 8) <= "000000000000000000000000"; 
          shift_cy_out <= op1 (23);
        when "11001" =>
          shift_output(6 downto 0) <= op1 (31 downto 25);
          shift_output(31 downto 7) <= "0000000000000000000000000"; 
          shift_cy_out <= op1 (24);
        when "11010" =>
          shift_output(5 downto 0) <= op1 (31 downto 26);
          shift_output(31 downto 6) <= "00000000000000000000000000"; 
          shift_cy_out <= op1 (25);
        when "11011" =>
          shift_output(4 downto 0) <= op1 (31 downto 27);
          shift_output(31 downto 5) <= "000000000000000000000000000"; 
          shift_cy_out <= op1 (26);
        when "11100" =>
          shift_output(3 downto 0) <= op1 (31 downto 28);
          shift_output(31 downto 4) <= "0000000000000000000000000000"; 
          shift_cy_out <= op1 (27);
        when "11101" =>
          shift_output(2 downto 0) <= op1 (31 downto 29);
          shift_output(31 downto 3) <= "00000000000000000000000000000"; 
          shift_cy_out <= op1 (28);
        when "11110" =>
          shift_output(1 downto 0) <= op1 (31 downto 30);
          shift_output(31 downto 2) <= "000000000000000000000000000000"; 
          shift_cy_out <= op1 (29);
        when "11111" =>
          shift_output(0) <= op1 (31);
          shift_output(31 downto 1) <= "0000000000000000000000000000000"; 
          shift_cy_out <= op1 (30);
        when others => NULL ;
      end case;
      
      --fin lsr
    end if;


    -- decalage arithmetique droit
    if (dec_shift_lsl = '0') and (dec_shift_lsr = '0') and (dec_shift_asr = '1')
       and (dec_shift_ror = '0') and (dec_shift_rrx = '0')
    then
      case dec_shift_val is

        when "00000" =>
          shift_output <= op1;
          shift_cy_out <= '0';
        when "00001" =>
          shift_output(30 downto 0) <= op1 (31 downto 1);
          for i in 31 to 31 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (0);
        when "00010" =>
          shift_output(29 downto 0) <= op1 (31 downto 2);
          for i in 31 to 30 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (1);
        when "00011" =>
          shift_output(28 downto 0) <= op1 (31 downto 3);
          for i in 31 to 29 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (2);
        when "00100" =>
          shift_output(27 downto 0) <= op1 (31 downto 4);
          for i in 31 to 28 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (3);
        when "00101" =>
          shift_output(26 downto 0) <= op1 (31 downto 5);
          for i in 31 to 27 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (4);
        when "00110" =>
          shift_output(25 downto 0) <= op1 (31 downto 6);
          for i in 31 to 26 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (5);          
        when "00111" =>
          shift_output(24 downto 0) <= op1 (31 downto 7);
          for i in 31 to 25 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (6);          
        when "01000" =>
          shift_output(23 downto 0) <= op1 (31 downto 8);
          for i in 31 to 24 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (7);          
        when "01001" =>
          shift_output(22 downto 0) <= op1 (31 downto 9);
          for i in 31 to 23 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (8);          
        when "01010" =>
          shift_output(21 downto 0) <= op1 (31 downto 10);
          for i in 31 to 22 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (9);          
        when "01011" =>
          shift_output(20 downto 0) <= op1 (31 downto 11);
          for i in 31 to 21 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (10);          
        when "01100" =>
          shift_output(19 downto 0) <= op1 (31 downto 12);
          for i in 31 to 20 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (11);                    
        when "01101" =>
          shift_output(18 downto 0) <= op1 (31 downto 13);
          for i in 31 to 19 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (12);                    
        when "01110" =>
          shift_output(17 downto 0) <= op1 (31 downto 14);
          for i in 31 to 18 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (13);                    
        when "01111" =>
          shift_output(16 downto 0) <= op1 (31 downto 15);
          for i in 31 to 17 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (14);                    
        when "10000" =>
          shift_output(15 downto 0) <= op1 (31 downto 16);
          for i in 31 to 16 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (15);                    
        when "10001" =>
          shift_output(14 downto 0) <= op1 (31 downto 17);
          for i in 31 to 15 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (16);                    
        when "10010" =>
          shift_output(13 downto 0) <= op1 (31 downto 18);
          for i in 31 to 14 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (17);                    
        when "10011" =>
          shift_output(12 downto 0) <= op1 (31 downto 19);
          for i in 31 to 13 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (18);          
        when "10100" =>
          shift_output(11 downto 0) <= op1 (31 downto 20);
          for i in 31 to 12 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (19);          
        when "10101" =>
          shift_output(10 downto 0) <= op1 (31 downto 21);
          for i in 31 to 11 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (20);          
        when "10110" =>
          shift_output(9 downto 0) <=  op1 (31 downto 22);
          for i in 31 to 10 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (21);          
        when "10111" =>
          shift_output(8 downto 0) <= op1 (31 downto 23);
          for i in 31 to 9 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (22);          
        when "11000" =>
          shift_output(7 downto 0) <= op1 (31 downto 24);
          for i in 31 to 8 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (23);          
        when "11001" =>
          shift_output(6 downto 0) <= op1 (31 downto 25);
          for i in 31 to 7 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (24);          
        when "11010" =>
          shift_output(5 downto 0) <= op1 (31 downto 26);
          for i in 31 to 6 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (25);          
        when "11011" =>
          shift_output(4 downto 0) <= op1 (31 downto 27);
          for i in 31 to 5 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (26);          
        when "11100" =>
          shift_output(3 downto 0) <= op1 (31 downto 28);
          for i in 31 to 4 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (27);          
        when "11101" =>
          shift_output(2 downto 0) <= op1 (31 downto 29);
          for i in 31 to 3 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (28);          
        when "11110" =>
          shift_output(1 downto 0) <= op1 (31 downto 30);
          for i in 31 to 2 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (29);          
        when "11111" =>
          shift_output(0) <= op1 (31);
          for i in 31 to 1 loop
            shift_output(i) <= op1(31);
          end loop;  -- i
          shift_cy_out <= op1 (30);          

        when others => NULL ;
      end case;
      
      --fin asr
    end if;


    -- rotation droit
    if (dec_shift_lsl = '0') and (dec_shift_lsr = '0') and (dec_shift_asr = '0')
       and (dec_shift_ror = '1') and (dec_shift_rrx = '0')
    then
      case dec_shift_val is

        when "00000" =>
            shift_output <= op1;
          shift_cy_out <= '0';          
        when "00001" =>
            shift_output <= op1(0) & op1(31 downto 1);
          shift_cy_out <= op1 (0);          
        when "00010" =>
            shift_output <= op1(1 downto 0) & op1(31 downto 2);
            shift_cy_out <= op1 (1);          
        when "00011" =>
            shift_output <= op1(2 downto 0) & op1(31 downto 3);
            shift_cy_out <= op1 (2);          
        when "00100" =>
            shift_output <= op1(3 downto 0) & op1(31 downto 4);
          shift_cy_out <= op1 (3);                    
        when "00101" =>
          shift_output <= op1(4 downto 0) & op1(31 downto 5);
          shift_cy_out <= op1 (4);                    
        when "00110" =>
          shift_output <= op1(5 downto 0) & op1(31 downto 6);
          shift_cy_out <= op1 (5);                    
        when "00111" =>
          shift_output <= op1(6 downto 0) & op1(31 downto 7);
          shift_cy_out <= op1 (6);                    
        when "01000" =>
          shift_output <= op1(7 downto 0) & op1(31 downto 8);
          shift_cy_out <= op1 (7);                    
        when "01001" =>
          shift_output <= op1(8 downto 0) & op1(31 downto 9);
          shift_cy_out <= op1 (8);                    
        when "01010" =>
          shift_output <= op1(9 downto 0) & op1(31 downto 10);
          shift_cy_out <= op1 (9);                    
        when "01011" =>
          shift_output <= op1(10 downto 0) & op1(31 downto 11);
          shift_cy_out <= op1 (10);                    
        when "01100" =>
          shift_output <= op1(11 downto 0) & op1(31 downto 12);
          shift_cy_out <= op1 (11);
        when "01101" =>
          shift_output <= op1(12 downto 0) & op1(31 downto 13);
          shift_cy_out <= op1 (12);          
        when "01110" =>
          shift_output <= op1(13 downto 0) & op1(31 downto 14);
          shift_cy_out <= op1 (13);          
        when "01111" =>
          shift_output <= op1(14 downto 0) & op1(31 downto 15);
          shift_cy_out <= op1 (14);          
        when "10000" =>
          shift_output <= op1(15 downto 0) & op1(31 downto 16);
          shift_cy_out <= op1 (15);          
        when "10001" =>
          shift_output <= op1(16 downto 0) & op1(31 downto 17);
          shift_cy_out <= op1 (16);          
        when "10010" =>
          shift_output <= op1(17 downto 0) & op1(31 downto 18);
          shift_cy_out <= op1 (17);          
        when "10011" =>
          shift_output <= op1(18 downto 0) & op1(31 downto 19);
          shift_cy_out <= op1 (18);          
        when "10100" =>
          shift_output <= op1(19 downto 0) & op1(31 downto 20);
          shift_cy_out <= op1 (19);          
        when "10101" =>
          shift_output <= op1(20 downto 0) & op1(31 downto 21);
          shift_cy_out <= op1 (20);
        when "10110" =>
          shift_output <= op1(21 downto 0) & op1(31 downto 22);
          shift_cy_out <= op1 (21);          
        when "10111" =>
          shift_output <= op1(22 downto 0) & op1(31 downto 23);
          shift_cy_out <= op1 (22);          
        when "11000" =>
          shift_output <= op1(23 downto 0) & op1(31 downto 24);
          shift_cy_out <= op1 (23);          
        when "11001" =>
          shift_output <= op1(24 downto 0) & op1(31 downto 25);
          shift_cy_out <= op1 (24);          
        when "11010" =>
          shift_output <= op1(25 downto 0) & op1(31 downto 26);
          shift_cy_out <= op1 (25);          
        when "11011" =>
          shift_output <= op1(26 downto 0) & op1(31 downto 27);
          shift_cy_out <= op1 (26);          
        when "11100" =>
          shift_output <= op1(27 downto 0) & op1(31 downto 28);
          shift_cy_out <= op1 (27);          
        when "11101" =>
          shift_output <= op1(28 downto 0) & op1(31 downto 29);
          shift_cy_out <= op1 (28);          
        when "11110" =>
          shift_output <= op1(29 downto 0) & op1(31 downto 30);
          shift_cy_out <= op1 (29);          
        when "11111" =>
          shift_output <= op1(30 downto 0) & op1(31);
          shift_cy_out <= op1 (30);
        when others => NULL ;
      end case;
      
      --fin ror
    end if;


    -- rrx
    if (dec_shift_lsl = '0') and (dec_shift_lsr = '0') and (dec_shift_asr = '0')
       and (dec_shift_ror = '0') and (dec_shift_rrx = '1')
    then
      shift_output <= shift_cy & op1(31 downto 1);
      shift_cy_out <= op1 (0);      
      --fin rrx
    end if;
    
    

   end process;

  end DataFlow;
