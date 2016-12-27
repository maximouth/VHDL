library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity decod_tb is
end decod_tb;

architecture Structurel of decod_tb is
  --  Declaration un composant
  component decod
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
    vss			: in bit
  );
  end component;    


begin
  process

  begin
  
    --  Wait forever; this will finish the simulation.    
    wait;
  end process;
end Structurel;
