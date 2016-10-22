library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
	port(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;
			exe_pop			: out Std_logic;

	-- Decode interface operands
			dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: in Std_Logic; -- Rd destination write back
			dec_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R

			dec_mem_lw		: in Std_Logic;
			dec_mem_lb		: in Std_Logic;
			dec_mem_sw		: in Std_Logic;
			dec_mem_sb		: in Std_Logic;

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;
			dec_shift_lsr	: in Std_Logic;
			dec_shift_asr	: in Std_Logic;
			dec_shift_ror	: in Std_Logic;
			dec_shift_rrx	: in Std_Logic;
			dec_shift_val	: in Std_Logic_Vector(4 downto 0);
			dec_cy			: in Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: in Std_Logic;
			dec_comp_op2	: in Std_Logic;
			dec_alu_cy 		: in Std_Logic;

	-- Alu command
			dec_alu_add		: in Std_Logic;
			dec_alu_and		: in Std_Logic;
			dec_alu_or		: in Std_Logic;
			dec_alu_xor		: in Std_Logic;

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0);

			exe_c				: out Std_Logic;
			exe_v				: out Std_Logic;
			exe_n				: out Std_Logic;
			exe_z				: out Std_Logic;

			exe_dest			: out Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: out Std_Logic; -- Rd destination write back
			exe_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Mem interface
			exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register
			exe_mem_data	: out Std_Logic_Vector(31 downto 0);
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0);

			exe_mem_lw		: out Std_Logic;
			exe_mem_lb		: out Std_Logic;
			exe_mem_sw		: out Std_Logic;
			exe_mem_sb		: out Std_Logic;

			exe2mem_empty	: out Std_logic;
			mem_pop			: in Std_logic;

	-- global interface
			ck					: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in bit;
			vss				: in bit);
end EXec;

----------------------------------------------------------------------

architecture Behavior OF EXec is



  
    --  Declaration un composant mux
  component mux

    port (
      input1 : in Std_Logic_Vector (31 downto 0);
      input2 : in Std_Logic_Vector (31 downto 0);

      cmd : in Std_logic ;

      output : out Std_Logic_Vector (31 downto 0)
      );
  END component;





  ---
  ---  rajouter des signal pour les differents shift command
  ---
  ---
    --  Declaration un composant shift
  component shift

    port (
      
      op1 : in Std_Logic_Vector (31 downto 0);
      
      dec_cy			: in Std_Logic;
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
    --end shift
  END component;



    --  Declaration un composant unknown
  component unknown

    port (

      inputLW : Std_logic;
      inputLB : Std_logic;
      inputSW : Std_logic;
      inputSB : Std_logic;

      inputDATA : Std_Logic_Vector (31 downto 0);
      inputDEST : Std_Logic_Vector (31 downto 0);
      
      D2E_empty : in Std_Logic;
      D2E_pop : out Std_Logic_Vector (31 downto 0);
      
      fifo_push: out Std_logic ;
      fifo_full : in Std_Logic_Vector (31 downto 0)

      );
    --end unknown
  END component;

  
  -- declaration fifo
  component fifo 
    generic(WIDTH: positive := 1);       
    PORT(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout		: out std_logic_vector(WIDTH-1 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
END component;


  
  --  Declaration un composant alu
  component alu

    port (
      op1			: in Std_Logic_Vector(31 downto 0);
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

  -- end alu
  end component;

  --declaration   
  signal not_dec_op1 : Std_Logic_Vector (31 downto 0);
  signal not_dec_op2 : Std_Logic_Vector (31 downto 0);
  signal shift_output : Std_Logic_Vector (31 downto 0);        
  
  signal output1 : Std_Logic_Vector (31 downto 0);
  signal output2 : Std_Logic_Vector (31 downto 0);
  signal outputmux : Std_Logic_Vector (31 downto 0);        

  
  -- declaration alu
  signal op1, op2, res : Std_Logic_Vector (31 downto 0);
  signal cmd_add, cmd_and, cmd_or, cmd_xor, cin, cout, z, n, v, shift_cy : Std_Logic;     

  -- declaration fifo
  signal din : Std_Logic_Vector (1 downto 0);
  signal push, pop, full, empty : Std_Logic;     

  --declaration mux
  

  begin



--instatiation alu
    alu_0: alu
    port map (
      op1 => op1,
      op2 => op2,
      cmd_add => cmd_add,
      cmd_and => cmd_and,
      cmd_or  => cmd_or,
      cmd_xor => cmd_xor,
      cin => cin,
      cout => cout,       
      z => z,
      n => n,
      v => v,
   
  
   res => res
      );

-- instatiation fifo
  fifo_0: fifo
    port map (
      din => din,
      push => push,
      pop => pop,
      full => full,
      empty  => empty,
      ck => ck
      );

    -- mux op1
    muxop1 : mux
      port map (
        input1 => dec_op1,
        input2 => not_dec_op1,

        cmd => dec_comp_op1,
        output => output1
        );
  
    -- mux op2
    muxop2 : mux
      port map (
        input1 => shift_output,
        input2 => not_dec_op2,

        cmd => dec_comp_op1,
        output => output2
        );
  
    -- mux res alu
    muxresalu : mux
      port map (
        input1 => res,
        input2 => output1,

        cmd => dec_comp_op1,
        output => outputmux
        );


    -- SHIFT
    shift_0 : shift
      port map (
        op1 => dec_op2,
        dec_cy => dec_cy,		
        dec_shift_lsl => dec_shift_lsl,	
        dec_shift_lsr => dec_shift_lsr,	
        dec_shift_asr => dec_shift_asr,	
        dec_shift_ror => dec_shift_ror,	
        dec_shift_rrx => dec_shift_rrx,	
        dec_shift_val => dec_shift_val,

        shift_cy => shift_cy,
        shift_output => shift_output


        );


    ---- decription du comportement
    ---- qui est relier à qui

    


-- FIN    
end Behavior;
