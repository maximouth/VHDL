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
    dec2exe_pop		: in Std_logic;  -- Former exe_pop

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
    dec_pop	: out Std_Logic;  -- former dec_pop

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

-- RF inval ports
signal inval_exe_adr    : Std_Logic_Vector(3 downto 0);
signal inval_exe        : Std_Logic;

signal inval_mem_adr    : Std_Logic_Vector(3 downto 0);
signal inval_mem        : Std_Logic;

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

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
signal shift_lsl: Std_Logic;
signal shift_lsr: Std_Logic;
signal shift_asr: Std_Logic;
signal shift_ror: Std_Logic;
signal shift_rrx: Std_Logic;
signal shift_val: Std_Logic_Vector(4 downto 0);
signal cy	: Std_Logic;

-- Alu operand selection
signal comp_op1	: Std_Logic;
signal comp_op2	: Std_Logic;
signal alu_cy 	: Std_Logic;

-- Alu command
signal alu_add	: Std_Logic;
signal alu_and	: Std_Logic;
signal alu_or	: Std_Logic;
signal alu_xor	: Std_Logic;

-- DECOD FSM

type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
signal cur_state, next_state : state_type;
type state_run_type is (DECOD, );
signal cur_state, next_state : state_type;

begin

  dec2exec : fifo
    generic map (WIDTH => 129)
    port map (
      din        => dec2exe_oper_in,  --?
      dout       => dec2exe_oper,  -- ?
      push       => dec2exe_push,  --
      pop        => dec2exe_pop,   --
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
      pop        => dec2if_pop,   --
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
                                          
      reg_cry		=> cry,
      reg_zero		=> zero,
      reg_neg		=> neg,
      reg_ovr		=> ovr,
					               
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


        -- case if_ir (27 downto 26) is
        --   when "00" => -- ALU Command
        --     -- Init of the ALU command
        --     dec_alu_add   <= '0';
        --     dec_alu_and   <= '0';
        --     dec_alu_or    <= '0';
        --     dec_alu_xor   <= '0';
        --     dec_alu_cy    <= '0';
        --     dec_shift_lsl <= '0';
        --     dec_shift_lsr <= '0';
        --     dec_shift_asr <= '0';
        --     dec_shift_ror <= '0';
        --     dec_shift_rrx <= '0';
        --     dec_shift_val <= "00000";
        --     dec_comp_op1 <= '0';
        --     dec_comp_op2 <= '0';
        --     dec_cy <= '0';
        --     dec_exe_wb  <= '0';
        --     dec_flag_wb <= '0';
        --     -- decod of the dest register
        --     dec_exe_dest <= if_ir (15 downto 12);
            
        --     -- decod of the operande 1
        --     -- decod of the operande 2
        --     -- decod of the operator
        --     case if_ir (24 downto 21) is
        --       when "0000" => -- AND
        --         dec_alu_and <= '1';
        --         dec_exe_wb <= '1';
        --       when "0001" => -- EOR
        --         dec_alu_xor <= '1';
        --         dec_exe_wb <= '1';
        --       when "0010" => -- SUB
        --         dec_alu_add <= '1';
        --         dec_comp_op2 <= '1';
        --         dec_exe_wb <= '1';
        --       when "0011" => -- RSB
        --         dec_alu_add <= '1';
        --         dec_comp_op1 <= '1';
        --         dec_exe_wb <= '1';
        --       when "0100" => -- ADD
        --         dec_alu_add <= '1';
        --         dec_exe_wb <= '1';
        --       when "0101" => -- ADC
        --         dec_alu_add <= '1';
        --         dec_cy <= '1';
        --         dec_exe_wb <= '1';
        --       when "0110" => -- SBC ??
        --         dec_alu_add <= '1';
        --         dec_comp_op2 <= '1';
        --         dec_cy <= '1';
        --         dec_exe_wb <= '1';
        --       when "0111" => -- RSC ??
        --         dec_alu_add <= '1';
        --         dec_comp_op1 <= '1';
        --         dec_cy <= '1';
        --         dec_exe_wb <= '1';
        --       when "1000" => -- TST
        --         dec_alu_and <= '1';
        --         dec_flag_wb <= '1';
        --       when "1001" => -- TEQ
        --         dec_alu_xor <= '1';
        --         dec_flag_wb <= '1';
        --       when "1010" => -- CMP
        --         dec_alu_add <= '1';
        --         dec_comp_op2 <= '1';
        --         dec_flag_wb <= '1';
        --       when "1011" => -- CMN
        --         dec_alu_add <= '1';
        --         dec_flag_wb <= '1';
        --       when "1100" => -- ORR
        --         dec_alu_or <= '1';
        --         dec_exe_wb <= '1';
        --       when "1101" => -- MOV
        --         dec_alu_xor <= '1';
        --         dec_op1 <= X"00000000";
        --         dec_exe_wb <= '1';
        --       when "1110" => -- BIC
        --         dec_alu_and <= '1';
        --         dec_comp_op2 <= '1';
        --         dec_exe_wb <= '1';
        --       when "1111" => -- MVN
        --         dec_alu_xor <= '1';
        --         dec_op1 <= X"FFFFFFFF";
        --         dec_exe_wb <= '1';
        --       when others =>
        --         report "Invalid operator";
        --       end case;

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
  case cur_state is

    when FETCH =>
      dec2if_pop   <= '0';
      dec2exe_push <= '0';
      blink        <= '0';
      mtrans_shift <= '0';

      -- T2
      if dec2if_full = '0' and reg_pcv = '1' then
        next_state      <= RUN;
        state_run       <= DECOD;
        -- replace the fifo value by PC 
        dec2if_push	<= '1';
        dec2if_pop	<= '1';
        dec2if_pc_in    <= reg_pc;
        inc_pc          <= '1';
      else
      -- T1
      end if;

    when RUN =>
      --T1 / T7
      if if2dec_empty = '1' or dec2exe_full = '1' then
        next_state      <= FETCH;
      else
        -- if2dec_empty = 0, so if_ir can be interpreted
      case if_ir (31 downto 28) is 
        --EQ
        when "0000" => pred := exe_z;
        --NE
        when "0001" => pred := not (exe_z);
        --CS
        when "0010" => pred := exe_c;
        --CC
        when "0011" => pred := not (exe_c);
        -- MI
        when "0100" => pred := exe_n;
        -- PL
        when "0101" => pred := not (exe_n);
        -- VS
        when "0110" => pred := exe_v;
        -- VC
        when "0111" => pred := not (exe_v);
        --HI
        when "1000" => pred := exe_c and not (exe_v);
        --LS
        when "1001" => pred := exe_z and not (exe_c);
        --GE
        when "1010" => pred := not (exe_n xor exe_v);
        --LT
        when "1011" => pred := exe_n xor exe_v;
        --GT  
        when "1100" => pred := not(exe_z) and not (exe_n xor exe_v);
        -- LE
        when "1101" => pred := exe_z or (exe_n xor exe_v);
        -- AL
        when "1110" => pred := '1';
        when "1111" => pred := '0';
        when others => pred := '0';
                       report "Non initialized instruction";
      end case;

    when BRANCH =>
    when LINK =>
    when MTRANS =>

  end case;
end process;




end Behavior;
