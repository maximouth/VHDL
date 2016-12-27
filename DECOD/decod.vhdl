library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Decod is
  port(
    -- Exec  operands

    -- first alu input
    dec_op1		: out Std_Logic_Vector(31 downto 0);
    -- shifter input
    dec_op2		: out Std_Logic_Vector(31 downto 0);
    -- Rd destination
    dec_exe_dest	: out Std_Logic_Vector(3 downto 0);
    -- Rd destination write back
    dec_exe_wb		: out Std_Logic;
    -- CSPR modifiy
    dec_flag_wb		: out Std_Logic;                     

    -- Decod to mem via exec

    -- data to MEM
    dec_mem_data	: out Std_Logic_Vector(31 downto 0); 
    dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
    dec_pre_index 	: out Std_logic;

    dec_mem_lw		: out Std_Logic;
    dec_mem_lb		: out Std_Logic;
    dec_mem_sw		: out Std_Logic;
    dec_mem_sb		: out Std_Logic;

    -- Shifter command
    dec_shift_lsl	: out Std_Logic;
    dec_shift_lsr	: out Std_Logic;
    dec_shift_asr	: out Std_Logic;
    dec_shift_ror	: out Std_Logic;
    dec_shift_rrx	: out Std_Logic;
    dec_shift_val	: out Std_Logic_Vector(4 downto 0);
    dec_cy		: out Std_Logic;

    -- Alu operand selection
    dec_comp_op1	: out Std_Logic;
    dec_comp_op2	: out Std_Logic;
    dec_alu_cy 		: out Std_Logic;

    -- Exec Synchro
    dec2exe_empty	: out Std_Logic;
    exe_pop		: in Std_logic;

    -- Alu command
    dec_alu_add		: out Std_Logic;
    dec_alu_and		: out Std_Logic;
    dec_alu_or		: out Std_Logic;
    dec_alu_xor		: out Std_Logic;

    -- Exe Write Back to reg
    exe_res		: in Std_Logic_Vector(31 downto 0);

    -- CSPR
    exe_c		: in Std_Logic;
    exe_v		: in Std_Logic;
    exe_n		: in Std_Logic;
    exe_z		: in Std_Logic;

    -- Rd destination
    exe_dest		: in Std_Logic_Vector(3 downto 0);
    -- Rd destination write back
    exe_wb		: in Std_Logic;
    -- CSPR modifiy
    exe_flag_wb		: in Std_Logic;                    

    -- Ifetch interface
    dec_pc		: out Std_Logic_Vector(31 downto 0) ;
    -- INSTRUCTION lue
    if_ir		: in Std_Logic_Vector(31 downto 0) ;

    -- Ifetch synchro
    dec2if_empty	: out Std_Logic;
    if_pop		: in Std_Logic;

    if2dec_empty	: in Std_Logic;
    dec_pop		: out Std_Logic;

    -- Mem Write back to reg
    mem_res		: in Std_Logic_Vector(31 downto 0);
    mem_dest		: in Std_Logic_Vector(3 downto 0);
    mem_wb		: in Std_Logic;

    -- global interface
    ck			: in Std_Logic;
    reset_n		: in Std_Logic;
    vdd			: in bit;
    vss			: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

  component reg
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
      inval_adr1	: in Std_Logic_Vector(3 downto 0);
      inval1		: in Std_Logic;

      inval_adr2	: in Std_Logic_Vector(3 downto 0);
      inval2		: in Std_Logic;

      inval_czn	        : in Std_Logic;
      inval_ovr	        : in Std_Logic;

      -- PC
      reg_pc		: out Std_Logic_Vector(31 downto 0);
      reg_pcv		: out Std_Logic;
      inc_pc		: in  Std_Logic;

      -- global interface
      ck		: in Std_Logic;
      reset_n		: in Std_Logic;
      vdd		: in bit;
      vss		: in bit);
  end component;

  component fifo
    generic(WIDTH: positive);
    port(
      din		: in std_logic_vector(WIDTH-1 downto 0);
      dout		: out std_logic_vector(WIDTH-1 downto 0);

      -- commands
      push		: in std_logic;
      pop		: in std_logic;

      -- flags
      full		: out std_logic;
      empty		: out std_logic;

      reset_n	        : in std_logic;
      ck		: in std_logic;
      vdd		: in bit;
      vss		: in bit
      );
  end component;

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
      );
  end component;
  
  signal cond	: Std_Logic;
  signal condv	: Std_Logic;
  signal operv	: Std_Logic;

  signal regop_t  : Std_Logic;
  signal mult_t   : Std_Logic;
  signal swap_t   : Std_Logic;
  signal trans_t  : Std_Logic;
  signal mtrans_t : Std_Logic;
  signal branch_t : Std_Logic;

-- regop instructions
  signal and_i  : Std_Logic;
  signal eor_i  : Std_Logic;
  signal sub_i  : Std_Logic;
  signal rsb_i  : Std_Logic;
  signal add_i  : Std_Logic;
  signal adc_i  : Std_Logic;
  signal sbc_i  : Std_Logic;
  signal rsc_i  : Std_Logic;
  signal tst_i  : Std_Logic;
  signal teq_i  : Std_Logic;
  signal cmp_i  : Std_Logic;
  signal cmn_i  : Std_Logic;
  signal orr_i  : Std_Logic;
  signal mov_i  : Std_Logic;
  signal bic_i  : Std_Logic;
  signal mvn_i  : Std_Logic;

-- mult instruction
  signal mul_i  : Std_Logic;
  signal mla_i  : Std_Logic;

-- trans instruction
  signal ldr_i  : Std_Logic;
  signal str_i  : Std_Logic;
  signal ldrb_i : Std_Logic;
  signal strb_i : Std_Logic;

-- mtrans instruction
  signal ldm_i  : Std_Logic;
  signal stm_i  : Std_Logic;

-- branch instruction
  signal b_i    : Std_Logic;
  signal bl_i   : Std_Logic;

-- link
  signal blink  : Std_Logic;

-- Multiple transferts
  signal mtrans_shift : Std_Logic;

  signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
  signal mtrans_mask : Std_Logic_Vector(15 downto 0);
  signal mtrans_list : Std_Logic_Vector(15 downto 0);
  signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- RF read ports
  signal radr1 : Std_Logic_Vector(3 downto 0);
  signal rdata1 : Std_Logic_Vector(31 downto 0);
  signal rvalid1 : Std_Logic;

  signal radr2 : Std_Logic_Vector(3 downto 0);
  signal rdata2 : Std_Logic_Vector(31 downto 0);
  signal rvalid2 : Std_Logic;

  signal radr3 : Std_Logic_Vector(3 downto 0);
  signal rdata3 : Std_Logic_Vector(31 downto 0);
  signal rvalid3 : Std_Logic;

  signal radr4 : Std_Logic_Vector(3 downto 0);
  signal rdata4 : Std_Logic_Vector(31 downto 0);
  signal rvalid4 : Std_Logic;


-- RF inval ports
  signal inval_exe_adr : Std_Logic_Vector(3 downto 0);
  signal inval_exe : Std_Logic;

  signal inval_mem_adr : Std_Logic_Vector(3 downto 0);
  signal inval_mem : Std_Logic;

-- Flags
  signal cry	: Std_Logic;
  signal zero	: Std_Logic;
  signal neg	: Std_Logic;
  signal ovr	: Std_Logic;

  signal reg_cznv : Std_Logic;
  signal reg_vv : Std_Logic;

  signal inval_czn : Std_Logic;
  signal inval_ovr : Std_Logic;

-- PC
  signal reg_pc  : Std_Logic_Vector(31 downto 0);
  signal reg_pcv : Std_Logic;
  signal inc_pc  : Std_Logic;

-- FIFOs
  signal dec2if_full : Std_Logic;
  signal dec2if_push : Std_Logic;

  signal dec2exe_full : Std_Logic;
  signal dec2exe_push : Std_Logic;

-- Exec  operands
  signal op1		: Std_Logic_Vector(31 downto 0);
  signal op2		: Std_Logic_Vector(31 downto 0);
  signal alu_dest	: Std_Logic_Vector(3 downto 0);
  signal alu_wb		: Std_Logic;
  signal flag_wb	: Std_Logic;

  signal offset32	: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
  signal mem_data	: Std_Logic_Vector(31 downto 0);
  signal ld_dest	: Std_Logic_Vector(3 downto 0);
  signal pre_index 	: Std_logic;

  signal mem_lw		: Std_Logic;
  signal mem_lb		: Std_Logic;
  signal mem_sw		: Std_Logic;
  signal mem_sb		: Std_Logic;

-- Shifter command
  signal shift_lsl	: Std_Logic;
  signal shift_lsr	: Std_Logic;
  signal shift_asr	: Std_Logic;
  signal shift_ror	: Std_Logic;
  signal shift_rrx	: Std_Logic;
  signal shift_val	: Std_Logic_Vector(4 downto 0);
  signal cy		: Std_Logic;

-- Alu operand selection
  signal comp_op1	: Std_Logic;
  signal comp_op2	: Std_Logic;
  signal alu_cy 	: Std_Logic;

-- Alu command
  signal alu_add	: Std_Logic;
  signal alu_and	: Std_Logic;
  signal alu_or		: Std_Logic;
  signal alu_xor	: Std_Logic;

-- DECOD FSM

-- fifo 129 command
  signal din129         : Std_logic_vector (128 downto 0);
  signal dout129        : Std_logic_vector (128 downto 0);
  signal push129        : Std_Logic;
  signal pop129         : Std_Logic;
  signal full129        : Std_Logic;
  signal empty129       : Std_Logic;
  
-- fifo 32  command
  signal din32         : Std_logic_vector (128 downto 0);
  signal dout32        : Std_logic_vector (128 downto 0);
  signal push32        : Std_Logic;
  signal pop32         : Std_Logic;
  signal full32        : Std_Logic;
  signal empty32       : Std_Logic;

-- shift command
  signal op1_sh : Std_Logic_Vector (31 downto 0);
  signal dec_sh_val : Std_Logic_Vector (4 downto 0);      
  
  signal dec_sh_lsl : Std_logic;
  signal dec_sh_lsr : Std_logic;
  signal dec_sh_asr : Std_logic;
  signal dec_sh_ror : Std_logic;
  signal dec_sh_rrx : Std_logic;

  signal cy1 : std_logic;
  signal cy2 : std_logic;
  
  signal shift_output : Std_Logic_Vector (31 downto 0);

  
-- signal instruction
  signal instruction : Std_logic_vector (32 downto 0);

  
  type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
  signal cur_state, next_state : state_type;

  begin
    
    dec2exec : fifo
      generic map (WIDTH => 129)
      port map (
        reset_n	 => reset_n,
        ck	 => ck,
        vdd	 => vdd,
        vss	 => vss,
        din        => din129,
        dout       => dout129,
        push       => push129,
        pop        => pop129,
        full       => full129,
        empty      => empty129
        );

    dec2if : fifo
      generic map (WIDTH => 32)
      port map (

        reset_n	 => reset_n,
        ck	 => ck,
        vdd	 => vdd,
        vss	 => vss,
        din        => din32,
        dout       => dout32,
        push       => push32,
        pop        => pop32,
        full       => full32,
        empty      => empty32
        );

    reg_inst  : reg
      port map(	wdata1		=> exe_res,
                wadr1		=> exe_dest,
                wen1		=> exe_wb,

                wdata2		=> mem_res,
                wadr2		=> mem_dest,
                wen2		=> mem_wb,

                wcry		=> exe_c,
                wzero		=> exe_z,
                wneg		=> exe_n,
                wovr		=> exe_v,
                cspr_wb		=> exe_flag_wb,

                reg_rd1		=> rdata1,
                radr1		=> radr1,
                reg_v1		=> rvalid1,

                reg_rd2		=> rdata2,
                radr2		=> radr2,
                reg_v2		=> rvalid2,

                reg_rd3		=> rdata3,
                radr3		=> radr3,
                reg_v3		=> rvalid3,

                reg_rd4		=> rdata4,
                radr4		=> radr4,
                reg_v4		=> rvalid4,
                
                reg_cry		=> cry,
                reg_zero	=> zero,
                reg_neg		=> neg,
                reg_ovr		=> ovr,

                reg_cznv	=> reg_cznv,
                reg_vv		=> reg_vv,

                inval_adr1	=> inval_exe_adr,
                inval1		=> inval_exe,

                inval_adr2	=> inval_mem_adr,
                inval2		=> inval_mem,

                inval_czn	=> inval_czn,
                inval_ovr	=> inval_ovr,

                reg_pc		=> reg_pc,
                reg_pcv		=> reg_pcv,
                inc_pc		=> inc_pc,

                ck		=> ck,
                reset_n		=> reset_n,
                vdd		=> vdd,
                vss		=> vss);

-- Execution condition

-- FSM

    dec_pop <= '0';      -- put the instruction into fifo32
                         -- to decode and execute it
    dec2exe_push <= '0'; -- put something into the fifo to EXE
    blink <= '0';        -- make a link 
    mtrans_shift <= '0'; -- make a multiple transfert 
    dec2if_push	<= '0';  -- put nex address in fifo
    inc_pc <= '0';       -- pc += 4

    
    --state machine process.
    process (cur_state, dec2if_full, cond, condv, operv,
             dec2exe_full, if2dec_empty, reg_pcv, bl_i,
             branch_t, and_i, eor_i, sub_i, rsb_i, add_i,
              adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
             mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir,
             mtrans_rd, mtrans_mask_shift)

      variable cond    : Std_Logic;

    begin
      case cur_state is

        when FETCH =>
          
          -- T1 to FETCH
          if dec2if_full = '1' then
            next_state <= FETCH;
          else
          -- T2 to RUN
          if reg_pcv = '1' then
            next_state <= RUN;
            dec2if_push	<= '1';
            inc_pc <= '1';
          else
          -- Reg PC invalid -> Stay in FETCH state
            next_state <= FETCH;           
          end if;
          end if;

        when RUN =>

    --T1 to RUN
          if if2dec_empty = '1' and dec2exe_full = '1' then
            if dec2if_full = '0' then
              inc_pc <= '1';
              dec2if_push <= '1';
              --endif dec2if_full
            end if;
          --endif T1
          end if;


          -- T2/T3 to RUN
           -- regarder la condition d'execution
        case instruction (31 downto 28) is 
          --EQ
          when "0000" => cond := exe_z and '1';
          --NE
          when "0001" => cond := not (exe_z and '0');
          --CS
          when "0010" => cond := exe_c and '1';
          --CC
          when "0011" => cond := not (exe_c and '1');
          -- MI
          when "0100" => cond := exe_n and '1';
          -- PL
          when "0101" => cond := not (exe_n and '1');
          -- VS
          when "0110" => cond := exe_v and '1';
          -- VC
          when "0111" => cond := not (exe_v and '1');
          --HI
          when "1000" => cond := (exe_c and '1') and not (exe_v and '1');
          --LS
          when "1001" => cond := (exe_z and '1') and not (exe_c and '1');
          --GE
          when "1010" => --?
          --LT
          when "1011" => --?
          --GT  
          when "1100" => --?
          -- LE
          when "1101" => --?
          -- AL
          when "1110" => cond := '1';
          when others => cond := '0';
        end case;

          -- if pred true execute instruction
          if cond = '1' then
            if if2dec_empty = '1' then
              dec_pop <= '1';
            end if;
          -- throw it away
          else
            
          --end if cond = 1
          end if;

          next_state <= RUN;           

          -- T4 to LINK
          if instruction (27) = '1' and instruction (24) = '1' then
            next_state <= LINK;           
            blink <= '1';
          else
            -- T5 to BRANCH
          if instruction (27) = '1' and instruction (24) = '0' then
          next_state <= BRANCH;                       
          --end if T5
          end if;
          
        --end if t4          
        end  if;
      
        when LINK =>        
          -- T1 to BRANCH
          next_state <= BRANCH;
          
        when BRANCH =>
           -- T1 to BRANCH
          if if2dec_empty = '1' then -- si on a pas l'intruction dans
                                     -- le fifo
            next_state <= BRANCH;
          else
            -- T2 to RUN
            next_state <= RUN;
          -- end if T1
          end if;
          
          

        when MTRANS =>



      end case;
    -- state machine
    end process;

    -- decod process

    process (ck)


      variable rd_lu   : Std_logic_vector (3 downto 0);
      variable rn_lu   : Std_logic_vector (3 downto 0);
      variable rm_lu   : Std_logic_vector (3 downto 0);
      variable opcode  : Std_logic_vector (3 downto 0);

      variable rd_reg : Std_logic_vector (31 downto 0);
      variable rn_reg : Std_logic_vector (31 downto 0);
      variable rm_reg : Std_logic_vector (31 downto 0);
      variable op2_reg : Std_logic_vector (31 downto 0);
      
      variable val_dec : Std_logic_vector (4 downto 0);
      variable op2     : Std_logic_vector (31 downto 0);       
      

    begin

      if (rising_edge(ck)) then
        if (reset_n = '0') then
          cur_state <= Run;
        else
          cur_state <= next_state;
        --end reset
        end if;


        -- traitement 

        ---- si la condition est bonne continuer le decodage
        --if cond = '1' then
        --  --recuperer valeur
        --  opcode := instruction (24 downto 21);
        --  rn_lu  := instruction (19 downto 16);
        --  rd_lu  := instruction (15 downto 12);

        --  -- decoder l'operande 2
        --  if instruction (25) = '1' then
        --    --> immediat
        --    -- faire un shift rotation de valeur inst (11 downto 8)
        --    -- recuperer valeur dans variable 32 bit (op1 ou 2 dans fifo129)
            
        --  else
        --    --> registre
        --    rm_lu := instruction (3 downto 0);

        --    if instruction (4) = '0' then
        --      --valeur
        --      val_dec := instruction (11 downto 7);
        --    else
        --    --registre
        --    --lire valeur registre
        --    --  ->stocker les 5 premiers bits dans val_dec
        --      radr4 <= instruction (11 downto 8);
        --      op2_reg := rdata4;    
        --      val_dec := op2_reg (4 downto 0);
        --    end if;

        --  -- decodage operande2  
        --  end if;



        --  -- recuperer valeur contenue dans les registres
        --  radr1 <= rd_lu;
        --  rd_reg := rdata1;

        --  radr2 <= rn_lu;
        --  rn_reg := rdata2;

        --  radr3 <= rm_lu;
        --  rm_reg := rdata3;

          
        --  case instruction (6 downto 5) is
        --    -- ->mettre dans op2 la valeur de sortie du shifter
        --    -- lsl
        --    when "00" =>
        --      dec_sh_lsl <= '1';
        --      dec_sh_lsr <= '0';
        --      dec_sh_asr <= '0';
        --      dec_sh_ror <= '0';
        --      dec_sh_rrx <= '0';
        --      cy1 <= '0';
        --      cy2 <= '0';

        --      dec_sh_val <= val_dec;             
        --      op1_sh <= rm_reg; --valeur de rm lu dans reg
              
        --    --lsr
        --    when "01" =>
        --      dec_sh_lsl <= '0';
        --      dec_sh_lsr <= '1';
        --      dec_sh_asr <= '0';
        --      dec_sh_ror <= '0';
        --      dec_sh_rrx <= '0';
        --      cy1 <= '0';
        --      cy2 <= '0';

        --      dec_sh_val <= val_dec;             
        --      op1_sh <= rm_reg; --valeur de rm lu dans reg

        --    --asr
        --    when "10" =>
        --      dec_sh_lsl <= '0';
        --      dec_sh_lsr <= '0';
        --      dec_sh_asr <= '1';
        --      dec_sh_ror <= '0';
        --      dec_sh_rrx <= '0';
        --      cy1 <= '0';
        --      cy2 <= '0';

        --      dec_sh_val <= val_dec;             
        --      op1_sh <= rm_reg;--valeur de rm lu dans reg


        --    --ror
        --    when "11" =>
        --      dec_sh_lsl <= '0';
        --      dec_sh_lsr <= '0';
        --      dec_sh_asr <= '0';
        --      dec_sh_ror <= '1';
        --      dec_sh_rrx <= '0';
        --      cy1 <= '0';
        --      cy2 <= '0';

        --      dec_sh_val <= val_dec;             
        --      op1_sh <= rm_reg;--valeur de rm lu dans reg

        --    when others =>
        --      dec_sh_lsl <= '1';
        --      dec_sh_lsr <= '0';
        --      dec_sh_asr <= '0';
        --      dec_sh_ror <= '0';
        --      dec_sh_rrx <= '0';
        --      cy1 <= '0';
        --      cy2 <= '0';

        --      dec_sh_val <= "00000";             
        --      op1_sh     <= "00000000000000000000000000000000"; 

        --  end case;


        --  -- recuperer sortie du shifter
        --  op2 := shift_output;        


        --  -- recuperer l'opcode de l'instruction
        --  -- mettre tout les signaux en sortie a la bonne valeur pour exe
        --  -- remplir le fifo avec les bons trucs

        --  case instruction (24 downto 21) is
        --    -- AND
        --    when "0000" =>
        --      --alu operands
        --      dec_op1 <= rn_reg; 
        --      dec_op2 <= op2;

        --      dec_exe_dest <= rd_lu;
        --      dec_flag_wb <= '0';
        --      dec_flag_wb <= instruction (20);

        --      -- retirer la partie shift et la reporter sur EXE
        --      -- revoir comment marche EXE
              
        --    -- EOR
        --    when "0001" =>
        --    -- SUB
        --    when "0010" =>
        --    -- RSB
        --    when "0011" =>
        --    -- ADD
        --    when "0100" =>
        --    -- ADC
        --    when "0101" =>
        --    -- SBC
        --    when "0110" =>
        --    -- RSC
        --    when "0111" =>
        --    -- TST
        --    when "1000" =>
        --    -- TEQ
        --    when "1001" =>
        --    -- CMP
        --    when "1010" =>
        --    -- CMN
        --    when "1011" =>
        --    -- ORR
        --    when "1100" =>
        --    -- MOV
        --    when "1101" =>
        --    -- BIC
        --    when "1110" =>
        --    -- MVN
        --    when "1111" =>
        --    when others =>
              
        --  -- fin gestion instruction
        --  end case;
          
        ---- if condition bonne
        --end if;
        
        
        -- prendre la valeur dans instruction 
        -- -> regarder la condition d'execution 
        --    -> si different de "1110"
        --          -> regarder les flags
        --               -> si bon continuer le decodage
        --               -> sinon incrementer pc? (ou machine a etat?)
        --                  et attendre la prochaine instruction
        --                  
        ---> regarder opcode et decoder RS et RD
        --
        -- -> regarder le type de op2
        --    -> si 1 immediat
        --          -> 0->3 registre
        --          -> si 4 = 0
        --             -> 5->6 type decalage
        --             -> 7->11 valeur
        --          -> sinon
        --             -> 5->6 type decalage
        --             -> 8->11 registre qui contient la valeur
        --    -> si 0 registre
        --          -> 0->7  valeur operande
        --          -> 8->11 valeur rotation 
        
        


      --end rising edge
      end if;
    -- process clock
    end process;
    
  end Behavior;
