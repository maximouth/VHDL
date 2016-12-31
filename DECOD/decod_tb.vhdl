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
      dec_pop_out	: out Std_Logic;

      -- Mem Write back to reg
      mem_res		: in Std_Logic_Vector(31 downto 0);
      mem_dest		: in Std_Logic_Vector(3 downto 0);
      mem_wb		: in Std_Logic;

      -- global interface
      ck		: in Std_Logic;
      reset_n		: in Std_Logic;
      vdd		: in bit;
      vss		: in bit
      );
  end component;    


  -- first alu input
  signal dec_op1		: Std_Logic_Vector(31 downto 0);
  -- shifter input
  signal dec_op2		: Std_Logic_Vector(31 downto 0);
  -- Rd destination
  signal dec_exe_dest	        : Std_Logic_Vector(3 downto 0);
  -- Rd destination write back
  signal dec_exe_wb		: Std_Logic;
  -- CSPR modifiy
  signal dec_flag_wb		: Std_Logic;                     

  -- Decod to mem via exec

  -- data to MEM
  signal dec_mem_data	        : Std_Logic_Vector(31 downto 0); 
  signal dec_mem_dest	        : Std_Logic_Vector(3 downto 0);
  signal dec_pre_index 	        : Std_logic;

  signal dec_mem_lw		: Std_Logic;
  signal dec_mem_lb		: Std_Logic;
  signal dec_mem_sw		: Std_Logic;
  signal dec_mem_sb		: Std_Logic;

  -- Shifter command
  signal dec_shift_lsl	        : Std_Logic;
  signal dec_shift_lsr	        : Std_Logic;
  signal dec_shift_asr	        : Std_Logic;
  signal dec_shift_ror	        : Std_Logic;
  signal dec_shift_rrx	        : Std_Logic;
  signal dec_shift_val	        : Std_Logic_Vector(4 downto 0);
  signal dec_cy		        : Std_Logic;

  -- Alu operand selection
  signal dec_comp_op1	        : Std_Logic;
  signal dec_comp_op2	        : Std_Logic;
  signal dec_alu_cy 		: Std_Logic;

  -- Exec Synchro
  signal dec2exe_empty	        : Std_Logic;
  signal exe_pop		: Std_logic;

  -- Alu command
  signal dec_alu_add		: Std_Logic;
  signal dec_alu_and		: Std_Logic;
  signal dec_alu_or		: Std_Logic;
  signal dec_alu_xor		: Std_Logic;

  -- Exe Write Back to reg
  signal exe_res		: Std_Logic_Vector(31 downto 0);

  -- CSPR
  signal exe_c		        : Std_Logic;
  signal exe_v		        : Std_Logic;
  signal exe_n		        : Std_Logic;
  signal exe_z		        : Std_Logic;

  -- Rd destination
  signal exe_dest		: Std_Logic_Vector(3 downto 0);
  -- Rd destination write back
  signal exe_wb		        : Std_Logic;
  -- CSPR modifiy
  signal exe_flag_wb		: Std_Logic;                    

  -- Ifetch interface
  signal dec_pc		        : Std_Logic_Vector(31 downto 0) ;
  -- INSTRUCTION lue
  signal if_ir		        : Std_Logic_Vector(31 downto 0) ;

  -- Ifetch synchro
  signal dec2if_empty	        : Std_Logic;
  signal if_pop		        : Std_Logic;

  signal if2dec_empty	        : Std_Logic;
  signal dec_pop_out		: Std_Logic;

  -- Mem Write back to reg
  signal mem_res		: Std_Logic_Vector(31 downto 0);
  signal mem_dest		: Std_Logic_Vector(3 downto 0);
  signal mem_wb		        : Std_Logic;

  -- global interface
  signal ck			: Std_Logic;
  signal reset_n		: Std_Logic;
  signal vdd			: bit;
  signal vss			: bit;
    
    

begin
  
  Decod_0 : decod
    port map (
      -- first alu input
      dec_op1		=> dec_op1,
      -- shifter input
      dec_op2		=> dec_op2,
      -- Rd destination
      dec_exe_dest	=> dec_exe_dest,
      -- Rd destination write back
      dec_exe_wb	=> dec_exe_wb,
      -- CSPR modifiy
      dec_flag_wb	=> dec_flag_wb,                   

      -- Decod to mem via exec

      -- data to MEM
      dec_mem_data	=> dec_mem_data, 
      dec_mem_dest	=> dec_mem_dest,
      dec_pre_index 	=> dec_pre_index,

      dec_mem_lw	=> dec_mem_lw,
      dec_mem_lb	=> dec_mem_lb,
      dec_mem_sw	=> dec_mem_sw,
      dec_mem_sb	=> dec_mem_sb,

      -- Shifter command
      dec_shift_lsl	=> dec_shift_lsl,
      dec_shift_lsr	=> dec_shift_lsr,
      dec_shift_asr	=> dec_shift_asr,
      dec_shift_ror	=> dec_shift_ror,
      dec_shift_rrx	=> dec_shift_rrx,
      dec_shift_val	=> dec_shift_val,
      dec_cy		=> dec_cy,

      -- Alu operand selection
      dec_comp_op1	=> dec_comp_op1,
      dec_comp_op2	=> dec_comp_op2,
      dec_alu_cy 	=> dec_alu_cy,

      -- Exec Synchro
      dec2exe_empty	=> dec2exe_empty,
      exe_pop		=> exe_pop,

      -- Alu command
      dec_alu_add	=> dec_alu_add,
      dec_alu_and	=> dec_alu_and,
      dec_alu_or	=> dec_alu_or,
      dec_alu_xor	=> dec_alu_xor,

      -- Exe Write Back to reg
      exe_res		=> exe_res, 

      -- CSPR
      exe_c		=> exe_c,
      exe_v		=> exe_v,
      exe_n		=> exe_n,
      exe_z		=> exe_z,

      -- Rd destination
      exe_dest		=> exe_dest, 
      -- Rd destination write back
      exe_wb		=> exe_wb,
      -- CSPR modifiy
      exe_flag_wb	=> exe_flag_wb,                  

      -- Ifetch interface
      dec_pc		=> dec_pc,
      -- INSTRUCTION lue
      if_ir		=> if_ir,

      -- Ifetch synchro
      dec2if_empty	=> dec2if_empty,
      if_pop		=> if_pop,

      if2dec_empty	=> if2dec_empty,
      dec_pop_out	=> dec_pop_out,

      -- Mem Write back to reg
      mem_res		=> mem_res, 
      mem_dest		=> mem_dest,
      mem_wb		=> mem_wb,

      -- global interface
      ck		=> ck,
      reset_n		=> reset_n,
      vdd		=> vdd,
      vss		=> vss
      );

  process
    variable step:natural;
    variable time_step:natural;
    
  begin
    step := 0;
    time_step := 10;
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    vss <= '1';
    vdd <= '0';

    reset_n <= '0';

    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

    -- wire up all the entries i decod
    mem_wb   <= '1';
    mem_res  <= x"00000001";
    mem_dest <= "0000";

    exe_flag_wb <= '1';
    exe_c <= '1';
    exe_v <= '1';
    exe_n <= '1';
    exe_z <= '1';
    
    exe_wb   <= '0';
    exe_dest <= "0000";
    exe_res  <= x"00000000";
    
    
    reset_n  <= '1';
    
    -- mv r2 1
    if_ir <= "11100011101100000010000000000001"; 
    
    if2dec_empty <= '1';
    exe_pop <= '1';
    if_pop <= '0';
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

    --if_ir <= "11110011101100000010000000000001"; 
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

        ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

        ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

        ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

        ck <= '1';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";
    
    ck <= '0';
    wait for 10 ns;
    step := step + 1;
    report "-----------" & natural'image(step*time_step) & " ns";

    -- mv r5 2

    -- add r3 r3 r5
    
    --  Wait forever; this will finish the simulation.    
    wait;
  end process;
end Structurel;
