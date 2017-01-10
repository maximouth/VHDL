library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
  port(
    -- Exec  operands
    dec_op1: out Std_Logic_Vector(31 downto 0); -- first alu input
    dec_op2: out Std_Logic_Vector(31 downto 0); -- shifter input
    dec_exe_dest: out Std_Logic_Vector(3 downto 0); -- Rd destination
    dec_exe_wb	: out Std_Logic; -- Rd destination write back
    dec_flag_wb	: out Std_Logic; -- CSPR modifiy

    -- Decod to mem via exec
    dec_mem_data: out Std_Logic_Vector(31 downto 0); -- data to MEM
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

    exe_c		: in Std_Logic;
    exe_v		: in Std_Logic;
    exe_n		: in Std_Logic;
    exe_z		: in Std_Logic;

    exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
    exe_wb	: in Std_Logic; -- Rd destination write back
    exe_flag_wb	: in Std_Logic; -- CSPR modifiy

    -- Ifetch interface
    dec2if_pc	: out Std_Logic_Vector(31 downto 0) ;  -- former dec_pc
    if_ir	: in Std_Logic_Vector(31 downto 0) ;

    -- Ifetch synchro
    dec2if_empty: out Std_Logic;
    if2dec_pop	: in Std_Logic;  -- former if_pop

    if2dec_empty: in Std_Logic;
    dec_pop	: out Std_Logic;

    -- Mem Write back to reg
    mem_res	: in Std_Logic_Vector(31 downto 0);
    mem_dest	: in Std_Logic_Vector(3 downto 0);
    mem_wb	: in Std_Logic;
			
    -- global interface
    ck		: in Std_Logic;
    reset_n	: in Std_Logic;
    vdd		: in bit;
    vss		: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component reg
  port(
    -- Write Port 1 prioritaire
    wdata1	: in Std_Logic_Vector(31 downto 0);
    wadr1	: in Std_Logic_Vector(3 downto 0);
    wen1	: in Std_Logic;

    -- Write Port 2 non prioritaire
    wdata2	: in Std_Logic_Vector(31 downto 0);
    wadr2	: in Std_Logic_Vector(3 downto 0);
    wen2	: in Std_Logic;

    -- Write CSPR Port
    wcry	: in Std_Logic;
    wzero	: in Std_Logic;
    wneg	: in Std_Logic;
    wovr	: in Std_Logic;
    cspr_wb	: in Std_Logic;
		
    -- Read Port 1 32 bits
    reg_rd1	: out Std_Logic_Vector(31 downto 0);
    radr1	: in Std_Logic_Vector(3 downto 0);
    reg_v1	: out Std_Logic;

    -- Read Port 2 32 bits
    reg_rd2	: out Std_Logic_Vector(31 downto 0);
    radr2	: in Std_Logic_Vector(3 downto 0);
    reg_v2	: out Std_Logic;

    -- Read Port 3 32 bits
    reg_rd3	: out Std_Logic_Vector(31 downto 0);
    radr3	: in Std_Logic_Vector(3 downto 0);
    reg_v3	: out Std_Logic;

    -- Read Port 3 32 bits
    reg_rd4	: out Std_Logic_Vector(31 downto 0);
    radr4	: in Std_Logic_Vector(3 downto 0);
    reg_v4	: out Std_Logic;

    -- read CSPR Port
    reg_cry	: out Std_Logic;
    reg_zero	: out Std_Logic;
    reg_neg	: out Std_Logic;
    reg_cznv	: out Std_Logic;
    reg_ovr	: out Std_Logic;
    reg_vv	: out Std_Logic;
		
    -- Invalidate Port 
    inval_adr1	: in Std_Logic_Vector(3 downto 0);
    inval1	: in Std_Logic;

    inval_adr2	: in Std_Logic_Vector(3 downto 0);
    inval2	: in Std_Logic;

    inval_czn	: in Std_Logic;
    inval_ovr	: in Std_Logic;

    -- PC
    reg_pc	: out Std_Logic_Vector(31 downto 0);
    reg_pcv	: out Std_Logic;
    inc_pc	: in Std_Logic;
	
    -- global interface
    ck		: in Std_Logic;
    reset_n	: in Std_Logic;
    vdd		: in bit;
    vss		: in bit);
end component;

component fifo
  generic(WIDTH: positive);
  port(
    din		: in std_logic_vector(WIDTH-1 downto 0);
    dout	: out std_logic_vector(WIDTH-1 downto 0);

    -- commands
    push	: in std_logic;
    pop		: in std_logic;

    -- flags
    full	: out std_logic;
    empty	: out std_logic;

    reset_n	: in std_logic;
    ck		: in std_logic;
    vdd		: in bit;
    vss		: in bit
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
signal blink    : Std_Logic;

-- Multiple transferts
signal mtrans_shift : Std_Logic;

signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
signal mtrans_mask      : Std_Logic_Vector(15 downto 0);
signal mtrans_list      : Std_Logic_Vector(15 downto 0);
signal mtrans_rd        : Std_Logic_Vector(3 downto 0);

-- RF read ports
signal radr1    : Std_Logic_Vector(3 downto 0);
signal rdata1   : Std_Logic_Vector(31 downto 0);
signal rvalid1  : Std_Logic;

signal radr2    : Std_Logic_Vector(3 downto 0);
signal rdata2   : Std_Logic_Vector(31 downto 0);
signal rvalid2  : Std_Logic;

signal radr3    : Std_Logic_Vector(3 downto 0);
signal rdata3   : Std_Logic_Vector(31 downto 0);
signal rvalid3  : Std_Logic;

signal radr4    : Std_Logic_Vector(3 downto 0);
signal rdata4   : Std_Logic_Vector(31 downto 0);
signal rvalid4  : Std_Logic;


-- RF inval ports
signal inval_exe_adr    : Std_Logic_Vector(3 downto 0);
signal inval_exe        : Std_Logic;

signal inval_mem_adr    : Std_Logic_Vector(3 downto 0);
signal inval_mem        : Std_Logic;

-- Flags
signal reg_cry	: Std_Logic;
signal reg_zero	: Std_Logic;
signal reg_neg	: Std_Logic;
signal reg_ovr	: Std_Logic;

signal reg_cznv : Std_Logic;
signal reg_vv   : Std_Logic;

signal inval_czn : Std_Logic;
signal inval_ovr : Std_Logic;

-- PC
signal reg_pc   : Std_Logic_Vector(31 downto 0);
signal reg_pcv  : Std_Logic;
signal inc_pc   : Std_Logic;

-- FIFOs
signal dec2if_full : Std_Logic;
signal dec2if_pop : Std_Logic;
signal dec2if_push : Std_Logic;
signal dec2if_pc_in  : Std_Logic_Vector(31 downto 0);

signal dec2exe_full : Std_Logic;
signal dec2exe_push : Std_Logic;
signal dec2exe_oper_in  : Std_Logic_Vector(128 downto 0);
signal dec2exe_oper     : Std_Logic_Vector(128 downto 0);


-- Exec  operands
signal op1	: Std_Logic_Vector(31 downto 0);
signal op2	: Std_Logic_Vector(31 downto 0);
signal alu_dest	: Std_Logic_Vector(3 downto 0);
signal alu_wb	: Std_Logic;
signal flag_wb	: Std_Logic;

signal offset32	: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
signal mem_data	: Std_Logic_Vector(31 downto 0);
signal ld_dest	: Std_Logic_Vector(3 downto 0);
signal pre_index: Std_logic;

signal mem_lw	: Std_Logic;
signal mem_lb	: Std_Logic;
signal mem_sw	: Std_Logic;
signal mem_sb	: Std_Logic;

-- Shifter command
signal shift_val_temp: Std_Logic_Vector(4 downto 0);


-- DECOD FSM

type state_type is (FETCH, RUN,
                    WAIT_REG_INST, INST_EXE,
                    WAIT_REG_MEM, INST_MEM,
                    BRANCH, LINK, MTRANS);
signal cur_state, next_state : state_type;

begin

  dec2exec : fifo
    generic map (WIDTH => 129)
    port map (
      din        => dec2exe_oper_in,  --?
      dout       => dec2exe_oper,  -- ?
      push       => dec2exe_push,  --
      pop        => exe_pop,   --
      full       => dec2exe_full,  --
      empty      => dec2exe_empty, --
      
      reset_n	=> reset_n,
      ck	=> ck,
      vdd	=> vdd,
      vss       => vss);

  dec2if : fifo
    generic map (WIDTH => 32)
    port map (
      din        => dec2if_pc_in,
      dout       => dec2if_pc,
      push       => dec2if_push,  --
      pop        => if2dec_pop,   --
      full       => dec2if_full,  --
      empty      => dec2if_empty, --

      reset_n   => reset_n,
      ck	=> ck,
      vdd	=> vdd,
      vss	=> vss);

  reg_inst  : reg
    port map(
      wdata1		=> exe_res,
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
                                          
      reg_cry		=> reg_cry,
      reg_zero		=> reg_zero,
      reg_neg		=> reg_neg,
      reg_ovr		=> reg_ovr,
					               
      reg_cznv		=> reg_cznv,
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

process (ck)
begin

  if (rising_edge(ck)) then
    if (reset_n = '0') then
      cur_state <= FETCH;  -- former RUN ?      
    else
      cur_state <= next_state;
    end if;    
  end if;

end process;



        --   when "01" => -- Memory Access
        --   when "10" => -- Multiple Memory Access or Branch
        --     if if_ir(25) = '1' then -- Branch Inst
        --     else  -- Multiple Memory Access
        --     end if;
        --   when "11" =>
        --     report "Illelgal instruction";
        --   when others =>
        --     report "Non initialized instruction";
        -- end case;




--state machine process
process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full,
         if2dec_empty, reg_pcv, bl_i, branch_t, and_i, eor_i, sub_i,
         rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
	 mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd,
         mtrans_mask_shift)
  
  variable pred : Std_Logic;
  variable rd   : Std_Logic_Vector(3 downto 0);
  variable rn   : Std_Logic_Vector(3 downto 0);
  variable rm   : Std_Logic_Vector(3 downto 0);
  
begin
  -- Initialize all the outputs to complete
  -- Init of the ALU command
  dec_alu_add   <= '0';
  dec_alu_and   <= '0';
  dec_alu_or    <= '0';
  dec_alu_xor   <= '0';
  dec_alu_cy    <= '0';
  dec_shift_lsl <= '0';
  dec_shift_lsr <= '0';
  dec_shift_asr <= '0';
  dec_shift_ror <= '0';
  dec_shift_rrx <= '0';
  dec_shift_val <= "00000";
  shift_val_temp <= "00000";
  dec_comp_op1 <= '0';
  dec_comp_op2 <= '0';
  dec_cy <= '0';
  dec_exe_wb  <= '0';
  dec_flag_wb <= '0';
  dec2exe_push <= '0';
  dec_pop <= '0';
  
  dec_mem_lb <= '0';
  dec_mem_lw <= '0';
  dec_mem_sb <= '0';
  dec_mem_sw <= '0';

  case cur_state is

    when FETCH =>
      dec_pop   <= '0';
      dec2exe_push <= '0';

      -- T2
      if dec2if_full = '0' and reg_pcv = '1' then
        next_state      <= RUN;
        -- Send a new PC value to component FETCH 
        dec2if_push	<= '1';
        dec2if_pc_in    <= reg_pc;
        inc_pc          <= '1';
      else
      -- T1
      end if;

    when RUN =>
      -- Is there an instruction to decode? 
      if if2dec_empty = '1' then
        -- No, wait for the FETCH component
        next_state      <= RUN;
      else
        -- if_ir can be interpreted
        -- by default the instruction should be executed
        pred := '1';
        case if_ir (31 downto 28) is 
        --EQ
        when "0000" =>
          if reg_cznv = '1' then
            pred := reg_zero;
          end if;
        --NE
        when "0001" =>
          if reg_cznv = '1' then
            pred := not (reg_zero);
          end if;       
        --CS
        when "0010" =>
          if reg_cznv = '1' then
            pred := reg_cry;
          end if;
        --CC
        when "0011" =>
          if reg_cznv = '1' then
            pred := not (reg_cry);
          end if;
        -- MI
        when "0100" =>
          if reg_cznv = '1' then
            pred := reg_neg;
          end if;
        -- PL
        when "0101" =>
          if reg_cznv = '1' then
            pred := not (reg_neg);
          end if;
        -- VS
        when "0110" =>
          if reg_vv = '1' then
            pred := reg_ovr;
          end if;
        -- VC
        when "0111" =>
          if reg_vv = '1' then
            pred := not (reg_ovr);
          end if;
        --HI
        when "1000" =>
          if reg_cznv = '1' and reg_vv = '1' then
            pred := reg_cry and not (reg_ovr);
          end if;
        --LS
        when "1001" =>
          if reg_cznv = '1' then
            pred := reg_zero and not (reg_cry);
          end if;
        --GE
        when "1010" =>
          if reg_cznv = '1' and reg_vv = '1' then
            pred := not (reg_neg xor reg_ovr);
          end if;     
        --LT
        when "1011" =>
          if reg_cznv = '1' and reg_vv = '1' then
            pred := reg_neg xor reg_ovr;
          end if;
        --GT  
        when "1100" =>
          if reg_cznv = '1' and reg_vv = '1' then
            pred := not(reg_zero) and not (reg_neg xor reg_ovr);
          end if;
        -- LE
        when "1101" =>
          if reg_cznv = '1' and reg_vv = '1' then
            pred := reg_zero or (reg_neg xor reg_ovr);
          end if;
        -- AL
        when "1110" =>
          pred := '1';
        when "1111" =>
          pred := '0';
        when others =>
          pred := '0';
          report "Non initialized instruction";
        end case;

        -- is the instruction to execute?
        if pred = '1' then
          -- yes, process the kind of instruction
          case if_ir (27 downto 26) is
            when "00" => -- This is a data processing
              -- Read Rn value
              radr1 <= if_ir(19 downto 16);
              -- Read Rd value
              radr4 <= if_ir(15 downto 12);
               
              -- Decod the registers todo
              if if_ir(25) = '0' then
                -- Oper 2 is a register
                -- Read Rm value
                radr2 <= if_ir(3 downto 0);
                if if_ir(4) = '1' then
                  -- Read shift value in register Rs
                  radr3 <= if_ir(11 downto 8);
                end if;
              else
                -- Oper 2 is a immediat value
                -- decod perform in INST_EXE state
              end if;
              -- Wait for REG answer  
              next_state <= WAIT_REG_INST;
            when "10" =>
              if if_ir(25) = '1' then
                -- This is a Branch todo
              else
                -- This is a multiple memory access todo
              end if;
            when "01" => -- this is a simple memory access todo
              -- Read Rn value
              radr1 <= if_ir(19 downto 16);

              -- Read Rd value
              radr4 <= if_ir(15 downto 12);
               
              
              -- Decod the registers todo
              if if_ir(25) = '1' then
                -- Oper 2 is a register
                -- Read Rm value
                radr2 <= if_ir(3 downto 0);
                if if_ir(4) = '1' then
                  -- Read shift value in register Rs
                  radr3 <= if_ir(11 downto 8);
                end if;
              else
                -- Oper 2 is a immediat value
                -- decod perform in INST_MEM state
              end if;
              -- Wait for REG answer  
              next_state <= WAIT_REG_MEM;
            when others =>
              report "Illegal instruction";
          end case;
        else
          -- no, pop the instruction
          -- fetch the next instruction
          dec_pop     <= '1';
          next_state  <= FETCH;
        end if;

      end if;

    when WAIT_REG_INST =>
      -- REG component provide the register values
      if dec2exe_full = '1' then
        -- wait exec to finish
        next_state <= WAIT_REG_INST;
      else
        -- send command to Exec
        next_state <= INST_EXE;
      end if;
      
    when INST_EXE =>
      -- prepare Operandes and operator to EXEC module
      -- as not pop performed on fetch fifo, if_ir is still valid
      -- prepare Rd
      dec_exe_dest <= if_ir(15 downto 12);
      
      -- prepare the oper 1
      if rvalid1 = '1' then
        -- set the oper 1 value
        dec_op1 <= rdata1;
      else
        -- ??             
      end if;
      
      -- prepare the oper 2
      if if_ir(25) = '0' then  -- Oper 2 is a register
        if rvalid2 = '1' then
        -- set the oper 2 value
          dec_op2 <= rdata2;
        else
          -- ??             
        end if;
        
        -- Set the shift value
        if if_ir(4) = '0' then
          dec_shift_val <= if_ir(11 downto 7);
          shift_val_temp <= if_ir(11 downto 7);
        else
          if rvalid3 = '1' then
            dec_shift_val <= rdata3(4 downto 0);
            shift_val_temp <= rdata3(4 downto 0);
          else
          -- ??             
          end if;
        end if;

        -- decod the shift
        case if_ir(6 downto 5) is
          when "00" => -- Logic shift left
            dec_shift_lsl <= '1';
          when "01" => -- Logic shift right
            dec_shift_lsr <= '1';
          when "10" => -- Arithmetic shift right
            dec_shift_asr <= '1';
          when "11" => -- Rotation
            if (shift_val_temp = "00000") then
              -- Rotate right with cry
              dec_shift_rrx <= '1';
            else
              -- Rotate right
              dec_shift_ror <= '1';
            end if;
          when others =>
            report "Illegal shift value";
        end case;

      else -- Oper 2 is an immediat
        -- set the oper 2 value
        dec_op2(31 downto 8) <= X"000000";
        dec_op2(7 downto 0) <= if_ir(7 downto 0);
        dec_shift_ror <= '1';
        dec_shift_val(4) <= '0';
        dec_shift_val(3 downto 0) <= if_ir(11 downto 8);
      end if;
      
      -- decode the opcode
      case if_ir (24 downto 21) is
        when "0000" => -- AND
          dec_alu_and <= '1';
          dec_exe_wb <= '1';          
        when "0001" => -- EOR
          dec_alu_xor <= '1';
          dec_exe_wb <= '1';
        when "0010" => -- SUB
          dec_alu_add <= '1';
          dec_comp_op2 <= '1';
          dec_exe_wb <= '1';
        when "0011" => -- RSB
          dec_alu_add <= '1';
          dec_comp_op1 <= '1';
          dec_exe_wb <= '1';
        when "0100" => -- ADD
          dec_alu_add <= '1';
          dec_exe_wb <= '1';
        when "0101" => -- ADC
          dec_alu_add <= '1';
          dec_alu_cy <= '1';
          dec_exe_wb <= '1';
        when "0110" => -- SBC ??
          dec_alu_add <= '1';
          dec_comp_op2 <= '1';
          dec_alu_cy <= '1';
          dec_exe_wb <= '1';
        when "0111" => -- RSC ??
          dec_alu_add <= '1';
          dec_comp_op1 <= '1';
          dec_alu_cy <= '1';
          dec_exe_wb <= '1';
        when "1000" => -- TST
          dec_alu_and <= '1';
          dec_flag_wb <= '1';
        when "1001" => -- TEQ
          dec_alu_xor <= '1';
          dec_flag_wb <= '1';
        when "1010" => -- CMP
          dec_alu_add <= '1';
          dec_comp_op2 <= '1';
          dec_flag_wb <= '1';
        when "1011" => -- CMN
          dec_alu_add <= '1';
          dec_flag_wb <= '1';
        when "1100" => -- ORR
          dec_alu_or <= '1';
          dec_exe_wb <= '1';
        when "1101" => -- MOV
          dec_alu_xor <= '1';
          dec_op1 <= X"00000000";
          dec_exe_wb <= '1';
        when "1110" => -- BIC
          dec_alu_and <= '1';
          dec_comp_op2 <= '1';
          dec_exe_wb <= '1';
        when "1111" => -- MVN
          dec_alu_xor <= '1';
          dec_op1 <= X"FFFFFFFF";
          dec_exe_wb <= '1';
        when others =>
          report "Invalid operator";
      end case;
      
      -- send command to Exec, no value to push as it is decode
      dec2exe_push <= '1';

      -- remove the current instruction from Fetch
      dec_pop <= '1';
      
      -- send next instruction to Fetch
      next_state <= FETCH;
      
    when WAIT_REG_MEM => 
      next_state <= INST_MEM;

      
      
    when INST_MEM => -- 
      -- prepare operandes todo

      dec_mem_dest <= if_ir (19 downto 16);
      dec_mem_data <= rdata4;

      -- op1
      op1 <= rdata1;
      dec_comp_op1 <= '0';

      -- alu operand
      dec_alu_add <= '1';
      dec_alu_and <= '0';
      dec_alu_or  <= '0';
      dec_alu_xor <= '0';
      dec_alu_cy  <= '0';

      
      dec_exe_wb   <= '0';
      dec_flag_wb  <= '0';
      dec_exe_dest <= x"0";
      
      -- if op2 is an immediat or not
      if if_ir(25) = '0' then

        -- op2
        op2 <= x"00" & "0000" & if_ir (11 downto 0);

      -- shift operand
        dec_shift_lsl <= '1';
        dec_shift_lsr <= '0';
        dec_shift_asr <= '0';
        dec_shift_ror <= '0';
        dec_shift_rrx <= '0';
        dec_shift_val <= "00000";
        dec_cy <= '0';
        
      else

        op2 <= rdata2;

        dec_shift_lsl <= '0';
        dec_shift_lsr <= '0';
        dec_shift_asr <= '0';
        dec_shift_ror <= '0';
        dec_shift_rrx <= '0';
     
        dec_cy <= '0';  
        
        case if_ir (6 downto 5) is

          when "00" =>
            --lsl
            dec_shift_lsl <= '1';

          when "01" =>
            --lsr
            dec_shift_lsr <= '1';

          when "10" =>
            -- asr
            dec_shift_asr <= '1';

          when "11" =>
            --ror
            dec_shift_ror <= '1';

          when others =>
            report "illegal state";
        end case;
        
        
        -- shift same as usual instruction
        if if_ir(4) = '0' then
          dec_shift_val <= x"000" & "000" & if_ir (11 downto 7); 
        else
          dec_shift_val <= rdata3(4 downto 0);
        end if;
        
        
      end if;


      
      -- prepare operator
      if if_ir(20) = '1' then
        if if_ir(22) = '1' then
          dec_mem_lb <= '1';
        else
          dec_mem_lw <= '1';
        end if;       
      else
        if if_ir(22) = '1' then
          dec_mem_sb <= '1';
        else
          dec_mem_sw <= '1';
        end if;       
      end if; 

      

      
      -- remove the current instruction from Fetch
      dec_pop <= '1';
      
      -- send next instruction to Fetch
      next_state <= FETCH;



    when LINK =>
      -- write PC + 4 in r14 for return address for function

      dec_op1       <= reg_pc;
      dec_comp_op1  <= '0';
      
      dec_op2       <= x"00_00_00_04";
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
      dec_shift_val <= "00000";
      dec_cy <= '0';

      next_state <= BRANCH;      
      
    when BRANCH =>
      
      dec_op1       <= Std_logic_vector (unsigned (reg_pc) + 4);
      dec_comp_op1  <= '0';
      
      dec_op2       <= "00000000" & if_ir (23 downto 0);
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
      
      -- remove the current instruction from Fetch
      dec_pop <= '1';
      
      -- send next instruction to Fetch
      next_state <= FETCH;      

    when MTRANS =>
    when others =>
      report "Illegal state";
  end case;
end process;




end Behavior;
