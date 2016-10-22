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

      inputLW : in Std_logic;
      inputLB : in Std_logic;
      inputSW : in Std_logic;
      inputSB : in Std_logic;

      inputDATA : in Std_Logic_Vector (31 downto 0);
      inputDEST : in Std_Logic_Vector (31 downto 0);
      
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

-----
----- FAIRE LES DECLARATIONS DES SIGNAUX POUR CHAQUES COMPOSANT
----- NE PAS REUTILISER CEUX DEJA DONNés DANS LES DEFNITIONS DES COMPOSANTQ
-----


  
  --declaration des signaux pour les differents elements

  -- declaration mux 1
  signal input1_mux1 : Std_Logic_Vector (31 downto 0);
  signal input2_mux1 : Std_Logic_Vector (31 downto 0);  

  signal output_mux1 : Std_Logic_Vector (31 downto 0);
  signal mux1_cmd : Std_Logic;        
  
  -- declaration mux 2
  signal input1_mux2 : Std_Logic_Vector (31 downto 0);
  signal input2_mux2 : Std_Logic_Vector (31 downto 0);  

  signal output_mux2 : Std_Logic_Vector (31 downto 0);
  signal mux2_cmd : Std_Logic;
  
  -- declaration mux 3
  signal input1_mux3 : Std_Logic_Vector (31 downto 0);
  signal input2_mux3 : Std_Logic_Vector (31 downto 0);  
  
  signal output_mux3 : Std_Logic_Vector (31 downto 0);        
  signal mux3_cmd : Std_Logic;
  
  -- declaration shift
  signal shift_input : Std_Logic_Vector (31 downto 0);        
  signal shift_dec_cy : Std_Logic;        

  signal shift_lsl : Std_Logic;
  signal shift_lsr : Std_Logic;
  signal shift_asr : Std_Logic;
  signal shift_ror : Std_Logic;
  signal shift_rrx : Std_Logic;
  signal shift_val : Std_Logic_Vector (4 downto 0);

  signal shift_out_cy : Std_Logic;
  signal shift_output : Std_Logic_Vector (31 downto 0);        

  
  -- declaration alu
  signal alu_op1 : Std_Logic_Vector (31 downto 0);
  signal alu_op2 : Std_Logic_Vector (31 downto 0);
  signal alu_res : Std_Logic_Vector (31 downto 0);
  
  signal alu_cmd_add : Std_Logic;
  signal alu_cmd_and : Std_Logic;
  signal alu_cmd_or : Std_Logic;
  signal alu_cmd_xor : Std_Logic;

  signal alu_cin : Std_Logic;
  signal alu_cout : Std_Logic;

  signal alu_z : Std_Logic;
  signal alu_n : Std_Logic;
  signal alu_v : Std_Logic;

  -- declaration fifo
  signal fifo_din : Std_Logic_Vector (1 downto 0);

  signal fifo_push : Std_Logic;     
  signal fifo_pop  : Std_Logic;     
  signal fifo_full : Std_Logic;     
  signal fifo_empty : Std_Logic;     
    
  -- declaration unknown
  signal unknown_inputLW : Std_Logic;
  signal unknown_inputLB : Std_logic;
  signal unknown_inputSW : Std_logic;
  signal unknown_inputSB : Std_logic;

  signal unknown_inputDATA : Std_Logic_Vector (31 downto 0);
  signal unknown_inputDEST : Std_Logic_Vector (31 downto 0);
      
  signal unknown_D2E_empty : Std_Logic;
  signal unknown_D2E_pop : Std_Logic_Vector (31 downto 0);
      
  signal unknown_fifo_push: Std_logic ;
  signal unknown_fifo_full : Std_Logic_Vector (31 downto 0);

  begin



-- Instanciation alu
    alu_0: alu
    port map (
      op1 => alu_op1,
      op2 => alu_op2,
      cmd_add => alu_cmd_add,
      cmd_and => alu_cmd_and,
      cmd_or  => alu_cmd_or,
      cmd_xor => alu_cmd_xor,
      cin => alu_cin,
      cout => alu_cout,       
      z => alu_z,
      n => alu_n,
      v => alu_v,
      res => alu_res
      );

-- Instanciation fifo
  fifo_0: fifo
    port map (
      din => fifo_din,
      push => fifo_push,
      pop => fifo_pop,
      full => fifo_full,
      empty  => fifo_empty,
      ck => ck
      );

-- Instanciation mux op1
    muxop1 : mux
      port map (
        input1 => input1_mux1,
        input2 => input2_mux1,

        cmd => mux1_cmd,
        output => output_mux1
        );
  
 -- Instanciation mux op2
    muxop2 : mux
      port map (
        input1 => input1_mux2,
        input2 => input2_mux2,

        cmd => mux2_cmd,
        output => output_mux2
        );
  
 -- Instanciation mux3 (res alu)
    muxresalu : mux
      port map (
        input1 => input1_mux3,
        input2 => input2_mux3,

        cmd => mux3_cmd,
        output => output_mux3
        );


 -- Instanciation SHIFT
    shift_0 : shift
      port map (
        op1 => shift_input,
        dec_cy => shift_dec_cy,		
        dec_shift_lsl => shift_lsl,	
        dec_shift_lsr => shift_lsr,	
        dec_shift_asr => shift_asr,	
        dec_shift_ror => shift_ror,	
        dec_shift_rrx => shift_rrx,	
        dec_shift_val => shift_val,

        shift_cy => shift_out_cy,
        shift_output => shift_output


        );

    -- Instanciation unknown 
    unknown_0 : unknown
      port map (
        inputLB => unknown_inputLB,
        inputLW => unknown_inputLW,
        inputSB => unknown_inputSB,
        inputSw => unknown_inputSW,

        inputDATA => unknown_inputDATA,
        inputDEST => unknown_inputDEST,

        D2E_empty => unknown_D2E_empty,

        fifo_full => unknown_fifo_full
        );

    ---- decription du comportement
    ---- qui est relier à qui

    
    


-- FIN    
end Behavior;
