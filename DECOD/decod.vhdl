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
    dec_pop_out		: out Std_Logic;

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
  
--  signal cond	: Std_Logic;
  signal condv	: Std_Logic;
  signal operv	: Std_Logic := '1';

  signal regop_t  : Std_Logic;
  signal mult_t   : Std_Logic;
  signal swap_t   : Std_Logic;
  signal trans_t  : Std_Logic;
  signal mtrans_t : Std_Logic;
  signal branch_t : Std_Logic;

  signal dec_pop  : Std_Logic := '0';
  
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
  signal bl_i   : Std_Logic := '0';

-- link
  signal blink  : Std_Logic;

-- Multiple transferts
  signal mtrans_shift : Std_Logic;

  signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
  signal mtrans_mask : Std_Logic_Vector(15 downto 0);
  signal mtrans_list : Std_Logic_Vector(15 downto 0);
  signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- RF read ports
  signal radr1 : Std_Logic_Vector(3 downto 0) := "0000";
  signal rdata1 : Std_Logic_Vector(31 downto 0);
  signal rvalid1 : Std_Logic;

  signal radr2 : Std_Logic_Vector(3 downto 0) := "0000";
  signal rdata2 : Std_Logic_Vector(31 downto 0);
  signal rvalid2 : Std_Logic;

  signal radr3 : Std_Logic_Vector(3 downto 0) := "0000";
  signal rdata3 : Std_Logic_Vector(31 downto 0);
  signal rvalid3 : Std_Logic;

  signal radr4 : Std_Logic_Vector(3 downto 0):= "0000";
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
  signal inc_pc  : Std_Logic := '0';

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
  signal din32         : Std_logic_vector (31 downto 0);
  signal dout32        : Std_logic_vector (31 downto 0);
  signal push32        : Std_Logic := '0';
  signal pop32         : Std_Logic := '0';
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
--  signal instruction : Std_logic_vector (31 downto 0);

  
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

  --dec_pop <= '0';      -- put the instruction into fifo32
  -- to decode and execute it
  --dec2exe_push <= '0'; -- put something into the fifo to EXE
  --blink <= '0';        -- make a link 
  --mtrans_shift <= '0'; -- make a multiple transfert 
  --dec2if_push  <= '0'; -- put nex address in fifo
  --inc_pc <= '0';       -- pc += 4

  
  --state machine process.
  process (cur_state, dec2if_full, condv, operv,
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
          report "in t1 FETCH";
        else

          -- T2 to RUN
          if reg_pcv = '1' then
            report "in t2 FETCH";       
            next_state <= RUN;
            dec2if_push	<= '1';
            inc_pc <= '1';
          else
            -- Reg PC invalid -> Stay in FETCH state
            next_state <= FETCH;           
          end if;
        end if;

      when RUN =>
        report "in run";       
        --T1 to RUN

        next_state <= RUN;
        
        if if2dec_empty = '1' and dec2exe_full = '1' then
          report "in T1 run";       
          if dec2if_full = '0' then
            inc_pc <= '1';
            dec2if_push <= '1';
          --endif dec2if_full
          end if;
          
        else

          -- T2/T3 to RUN
          -- regarder la condition d'execution

          if operv = '1' then
          report "in T2/T3 run";       
            if dec_pop = '0' then
            
            case if_ir (31 downto 28) is 
              --EQ
              when "0000" => cond := exe_z;
              --NE
              when "0001" => cond := not (exe_z);
              --CS
              when "0010" => cond := exe_c;
              --CC
              when "0011" => cond := not (exe_c);
              -- MI
              when "0100" => cond := exe_n;
              -- PL
              when "0101" => cond := not (exe_n);
              -- VS
              when "0110" => cond := exe_v;
              -- VC
              when "0111" => cond := not (exe_v);
              --HI
              when "1000" => cond := exe_c and not (exe_v);
              --LS
              when "1001" => cond := exe_z and not (exe_c);
              --GE
              when "1010" => cond := not (exe_n xor exe_v);
              --LT
              when "1011" => cond := exe_n xor exe_v;
              --GT  
              when "1100" => cond := not(exe_z) and not (exe_n xor exe_v);
              -- LE
              when "1101" => cond := exe_z or (exe_n xor exe_v);
              -- AL
              when "1110" => cond := '1';
                             report "cond bonne";
              when others => cond := '0';
            end case;

            -- if pred true execute instruction
            if cond = '1' then
              if if2dec_empty = '1' then
                dec_pop <= '1';
                operv <= '0';
                report "dec_pop T2/3: " & std_logic'image(dec_pop);
              end if;
            -- throw it away
            else
              
            --end if cond = 1
            end if;
          end if;
          
            
            -- T4 to LINK
            if if_ir (27) = '1' and if_ir (24) = '1' then
              report "in T4 RUN";
              next_state <= LINK;           
              blink <= '1';
            else
              -- T5 to BRANCH
              if if_ir (27) = '1' and if_ir (24) = '0' then
                report "in T5 RUN";
                next_state <= BRANCH;                       
              --end if T5
              end if;
            --end if t4          
            end if;

          end if;
        --endif T1
        end if;

        
        
      when LINK =>        
        report "in LINK";       
        -- T1 to BRANCH
        next_state <= BRANCH;
        
      when BRANCH =>
        report "in BRANCH";
        
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
        report "in MTRANS";

    end case;
  -- state machine
  end process;

  -- decod process 
  process 

    variable tmp     : Std_logic_vector (31 downto 0);
    
    variable rd_lu   : Std_logic_vector (3 downto 0);
    variable rn_lu   : Std_logic_vector (3 downto 0);
    variable rm_lu   : Std_logic_vector (3 downto 0);
    variable opcode  : Std_logic_vector (3 downto 0);

    variable rd_reg  : Std_logic_vector (31 downto 0);
    variable rs_reg  : Std_logic_vector (31 downto 0);
    variable rn_reg  : Std_logic_vector (31 downto 0);
    variable rm_reg  : Std_logic_vector (31 downto 0);
    variable op2_reg : Std_logic_vector (31 downto 0);
    
    variable val_dec : Std_logic_vector (4 downto 0);
    variable op2     : Std_logic_vector (31 downto 0);       
    

  begin

    wait until ck = '1';

    if (rising_edge(ck)) then
      report "-------------- in rising edge  ";
      
      if (reset_n = '0') then
        cur_state <= FETCH;

        report " in reset";
        
        --init cond
--        dec_pop <= '0';      -- put the instruction into fifo32
        -- to decode and execute it
        dec2exe_push <= '0'; -- put something into the fifo to EXE
        blink <= '0';        -- make a link 
        mtrans_shift <= '0'; -- make a multiple transfert 
        dec2if_push  <= '0'; -- put nex address in fifo
--        inc_pc <= '0';       -- pc += 4

        --reset fifo
        push32 <= '0';
        pop32  <= '0';
        --reset reg
        radr1 <= "1001";
        radr2 <= "1010";
        radr3 <= "0011";
        radr4 <= "1111";
      else
        report " next state: ";
        cur_state <= next_state;

      --end reset
      end if;

      
      -- ** gestion du write back en entrée **

      -- maj CSPR
      -- done in reg instantiaton
      if exe_flag_wb = '1' then
        inval_ovr <= '1';
        inval_czn <= '1';
      else
        inval_ovr <= '0';
        inval_czn <= '0';
      end if;
      
      
      --maj mem
      -- done in reg instantiaton
      
      --maj wb
      -- done in reg instantiaton        

      -- ** fin gestion du wr en entré **

      report "dec_pop: " & std_logic'image(dec_pop);
      report "dec2if_push: " & std_logic'image(dec2if_push);
--      report "dec_pop: " & std_logic'image(dec_pop);
--      report "dec_pop: " & std_logic'image(dec_pop);
--      report "dec_pop: " & std_logic'image(dec_pop);


      -- traitement 
      -- step 1
      -- send instruction address to dec2if
      if dec2if_push = '1' then
        report "Step 1" ;
--        inc_pc <= '0';

        if reg_pcv = '1' then
          report "reg_pcv = 1";
          dec_pc <= reg_pc;
        end if; 
      end if;
      
      -- step 2
      -- read instruction in instruction and store it into if2dec
      report "full32 : " & Std_Logic'image(full32);
      report "empty32 : " & Std_Logic'image(empty32);

      
      if dec_pop = '1'then
        report "Step 2" ;
        if full32 = '0' then
          report "remplisage fifo" ;
          din32   <= if_ir;
          push32  <= '1';
          pop32   <= '0';
          --dec_pop <= '0';

        end if;
      end if;
      
      -- step 3
      -- decode the instruction

      --if there is an instruction :
      if full32 = '1' then
        report "step 3";
        -- if instruction is a branch or a branch and link
        if dout32 (27) = '1' then 
          report "branch instruction";
          -- if a link save return add in r14 (pc +4)
          if blink = '1' then
          report "branch and link instruction";
            -- put the right thing to EXE to wb in r14

            dec_op1       <= reg_pc;
            dec_comp_op1  <= '0';

            dec_op2       <= x"00_00_00_04";
            dec_comp_op2  <= '0';

            dec_exe_dest  <= x"D";
            dec_exe_wb    <= '1';
            dec_flag_wb   <= '0';

            dec_alu_add   <= '1';
            dec_alu_and   <= '0';
            dec_alu_or    <= '0';
            dec_alu_xor   <= '0';
            dec_alu_cy    <= '0';

            dec_shift_lsl <= '1';
            dec_shift_lsr <= '0';
            dec_shift_asr <= '0';
            dec_shift_ror <= '0';
            dec_shift_rrx <= '0';
            dec_shift_val <= "00000";
            dec_cy <= '0';
            
            blink <= '0';
          else
            
            -- pc = pc + 8 + (offset * 4) "decalage gauche 2"
            -- mettre les fils en sortie avec wb sur r15

            tmp := reg_pc;
            tmp := Std_logic_vector (unsigned (tmp) + 4);
            
            dec_op1       <= tmp;
            dec_comp_op1  <= '0';

            dec_op2       <= "00000000" & dout32 (23 downto 0);
            dec_comp_op2  <= '0';

            dec_exe_dest  <= x"E";
            dec_exe_wb    <= '1';
            dec_flag_wb   <= '0';

            dec_alu_add   <= '1';
            dec_alu_and   <= '0';
            dec_alu_or    <= '0';
            dec_alu_xor   <= '0';
            dec_alu_cy    <= '0';

            dec_shift_lsl <= '1';
            dec_shift_lsr <= '0';
            dec_shift_asr <= '0';
            dec_shift_ror <= '0';
            dec_shift_rrx <= '0';
            dec_shift_val <= "00010";
            dec_cy <= '0';
            
          -- end if link
          end if;

          --acces memoire
          if dout32 (27) = '0' and dout32 (26) = '1'  then
          report "mem instruction";            
            ------- ********************************************** -----
            ------- ********************************************** -----
            --           rajouter acces memoire
            --           dout32 (27) = 0
            --           dout32 (26) = 1
            --
            --           rajouter :
            --                -> pré post indexation dout32 (24)
            --                -> UP down dout32 (23) 
            --
            --
            ------- ********************************************** -----
            ------- ********************************************** -----

            
            if dout32 (20) = '1' then
              -- load
              report "load inst";
              
              dec_mem_sb <= '0';
              dec_mem_sw <= '0';

              dec_mem_lb <= dout32 (22);
              dec_mem_lw <= not ( dout32 (22) );              
              
            else
              -- store
              report "store inst";
              dec_mem_lb <= '0';
              dec_mem_lw <= '0';

              dec_mem_sb <= dout32 (22);
              dec_mem_sw <= not ( dout32 (22) );

            --end load or store?
            end if;

            --get the address in rn 
            radr1  <= dout32 (19 downto 16);
            rn_reg := rdata1;

            dec_mem_dest <= dout32 (15 downto 12);
            dec_mem_data <= rn_reg;


            -- write back
            if dout32 (21) = '1' then

              dec_op1       <= rn_reg;

              dec_comp_op1  <= '0';
              dec_comp_op2  <= '0';

              dec_alu_cy    <= '0';
              
              dec_exe_wb    <= '1';
              dec_flag_wb   <= '0';
              dec_exe_dest  <= dout32 (15 downto 12); 

              dec_shift_val <= '0' & x"0" ;
              dec_shift_lsl <= '1';
              dec_shift_lsr <= '0';
              dec_shift_asr <= '0';
              dec_shift_ror <= '0';
              dec_shift_rrx <= '0';
              dec_cy        <= '0';
              
              if dout32 (22) = '1' then
                -- byte
                dec_op2 <= x"00_00_00_01"; 
              else
                --word
                dec_op2 <= x"00_00_00_04"; 
              end if;
            -- end write back
            end if;

            
          -- fin acces memoire
          end if;
          
        else
          report "normal inst";
          
          --decode the instruction
          -- get values
          opcode := dout32 (24 downto 21);
          rn_lu  := dout32 (19 downto 16);
          rd_lu  := dout32 (15 downto 12);

          report "opcode ";
          
          -- decode operand 2
          if dout32 (25) = '1' then
          report "op2 immediat";
            --> immediat
            -- dout32 (7  downto 0) into op2 alu
            -- dout32 (11 downto 8) into shift dec
            -- shift_rot <= '1';

            dec_op2 <= x"00_00_00" & dout32 (7  downto 0);
            val_dec := '0' & dout32 (11 downto 8);

            
          else
            --> registre

            --get the value in rm
            radr2  <= dout32 (3 downto 0);
            rm_reg := rdata2;

            
            if dout32 (4) = '1' then
              -- case value into reg (4 downto 0) = value shift

              ----------- ************************************ ------
              ----------- ************************************ ------
              ----------- charger la valeur de reg et mettre   ------
              ----------- les 5 premiers bits dans val_dec     ------
              ----------- ************************************ ------
              ----------- ************************************ ------
              
              --get the value in rs for shift value
              radr3  <= dout32 (11 downto 8);
              rs_reg := rdata3;
              val_dec := rs_reg (4 downto 0);
              
              
            else
              -- case value dout (11 downto 7)  = value shift 
              val_dec := dout32 (11 downto 7);
              
            -- endif dout32 (4) = 1  
            end if;
            
          --end if operande 2
          end if;

          -- init value for everyone
          dec_shift_lsl <= '0';
          dec_shift_lsr <= '0';
          dec_shift_asr <= '0';
          dec_shift_ror <= '0';
          dec_shift_rrx <= '0';
          dec_shift_val <= val_dec;
          dec_cy <= '0';

          dec_comp_op2 <= '0';
          dec_alu_cy   <= '0';
          
          -- put the right thing into all of the op2 of EXEC
          case dout32 (6 downto 5) is
            --lsl
            when "00" =>                  
              dec_shift_lsl <= '1';
            -- lsr
            when "01" =>
              dec_shift_lsr <= '1';
            --asr
            when "10" =>
              dec_shift_asr <= '1';
            --ror
            when "11" =>
              dec_shift_ror <= '1';              
            when others => --erreur
              
          -- end case on shift's type  
          end case;


          -- put the right flag midify or not
          dec_flag_wb <= dout32 (20);


          ----------- ************************************ ------
          ----------- ************************************ ------
          ----------- mettre tout les entres de l'alu a 0 et
          ----------- mettre a 1 dans le case (comme shift)
          -----------
          ----------- lire dans le banc de registre les valeur
          ----------- des registres a utiliser
          ----------- mettre rd comme valeur a dec_exe_dest
          -----------
          ----------- -> pour TST TEQ CMP CMN :
          ----------- verifier que mise jour flag = 1
          ----------- mettre  un dec_exe_dest indiferent
          ----------- dec_exe_wb a 0
          -----------
          ----------- si rien oublié c'est bon
          ----------- ************************************ ------
          ----------- ************************************ ------

          dec_alu_add   <= '0';
          dec_alu_and   <= '0';
          dec_alu_or    <= '0';
          dec_alu_xor   <= '0';
          dec_alu_cy    <= '0';
          
          -- get the value in rn
          radr1  <= dout32 (19 downto 16);
          rn_reg := rdata1;

          dec_op1      <= rn_reg;
          dec_comp_op1 <= '0';

          dec_op2      <= rm_reg;
          dec_comp_op2 <= '0';

          dec_exe_dest <= dout32 (15 downto 12);
          dec_exe_wb   <= '1';

          dec_flag_wb <= dout32 (20);


          
          -- now put all the right wire and things into fifo129 and
          -- to EXEC
          case dout32 (24 downto 21) is
            -- AND
            when "0000" =>
              --alu operands
              dec_alu_and   <= '1';

            -- EOR
            when "0001" =>
              dec_alu_xor   <= '1';
              
            -- SUB
            when "0010" =>
              dec_alu_add   <= '1';
              dec_comp_op1  <= '1';
              
            -- RSB
            when "0011" =>
              dec_alu_add   <= '1';
              dec_comp_op2  <= '1';
              
            -- ADD
            when "0100" =>
              dec_alu_add   <= '1';

            -- ADC
            when "0101" =>
              dec_alu_add   <= '1';
              dec_alu_cy <= '1';              
              
            -- SBC
            when "0110" =>

            -- RSC
            when "0111" =>

            -- TST
            when "1000" =>
              dec_exe_wb  <= '0';
              dec_flag_wb <= '1';
              dec_alu_and <= '1';
              
            -- TEQ
            when "1001" =>
              dec_exe_wb  <= '0';
              dec_flag_wb <= '1';
              dec_alu_xor <= '1';
              report "in TEQ";
              
            -- CMP
            when "1010" =>
              dec_exe_wb   <= '0';
              dec_flag_wb  <= '1';
              dec_alu_add  <= '1';
              dec_comp_op1 <= '1';
              report "in CMP";
              
            -- CMN
            when "1011" =>
              dec_exe_wb  <= '0';
              dec_flag_wb <= '1';
              dec_alu_and <= '1';
              report "in CMN";
              
            -- ORR
            when "1100" =>
              dec_alu_or   <= '1';              
              report "in ORR";
              
            -- MOV
            when "1101" =>
              dec_op1 <= x"00_00_00_00";
              dec_alu_add <= '1';
              report "in MOV";
              
            -- BIC
            when "1110" =>
              dec_alu_and  <= '1';
              dec_comp_op2 <= '1';
              
            -- MVN
            when "1111" =>
              dec_op1 <= x"00_00_00_00";
              dec_alu_add <= '1';
              dec_comp_op2 <= '1';
              
            when others =>
              
          -- fin gestion dout32
          end case;

          
        --end if type instruction  
        end if;
      --end if step 3  
      end if;


      -- step 4
      -- write into fifo129 and all the output wire to EXE

      
      
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
