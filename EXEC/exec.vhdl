library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
  port(
    -- Post indexation ?
    dec_PI : in Std_logic;
    
    -- Decode interface synchro
    dec2exe_empty	: in Std_logic;
    exe_pop		: out Std_logic;

    -- Decode interface operands

    -- first alu input
    dec_op1		: in Std_Logic_Vector(31 downto 0);
    -- shifter input
    dec_op2		: in Std_Logic_Vector(31 downto 0); 
    -- Rd destination
    dec_exe_dest	: in Std_Logic_Vector(3 downto 0);
    -- Rd destination write back
    dec_exe_wb		: in Std_Logic; 
    -- CSPR modifiy
    dec_flag_wb		: in Std_Logic; 

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
    dec_cy		: in Std_Logic;

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
    exe_res		: out Std_Logic_Vector(31 downto 0);

    exe_c		: out Std_Logic;
    exe_v		: out Std_Logic;
    exe_n		: out Std_Logic;
    exe_z		: out Std_Logic;

    exe_dest		: out Std_Logic_Vector(3 downto 0); -- Rd destination
    exe_wb		: out Std_Logic; -- Rd destination write back
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
    mem_pop		: in Std_logic;

    -- global interface
    ck			: in Std_logic;
    reset_n		: in Std_logic;
    vdd			: in bit;
    vss			: in bit);
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
      inputDEST : in Std_Logic_Vector (3 downto 0);

      inputMUX3 : in Std_Logic_Vector (31 downto 0);
      
      D2E_empty : in Std_Logic;
      D2E_pop : out Std_Logic;

      fifo_din : out Std_Logic_Vector ( 71 downto 0);       
      
      fifo_push: out Std_logic ;
      fifo_full : in Std_Logic; 
      ck : in Std_Logic
      
      );
    --end unknown
  END component;

  
  -- declaration fifo
  component fifo 
    generic(WIDTH: positive := 72);       
    PORT(
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

  --  *** declaration mux 1
  signal input1_mux1 : Std_Logic_Vector (31 downto 0);
  signal input2_mux1 : Std_Logic_Vector (31 downto 0);  

  signal output_mux1 : Std_Logic_Vector (31 downto 0);
  signal mux1_cmd : Std_Logic;        
  
  --  ***declaration mux 2
  signal input1_mux2 : Std_Logic_Vector (31 downto 0);
  signal input2_mux2 : Std_Logic_Vector (31 downto 0);  

  signal output_mux2 : Std_Logic_Vector (31 downto 0);
  signal mux2_cmd : Std_Logic;
  
  --  ***declaration mux 3
  signal input1_mux3 : Std_Logic_Vector (31 downto 0);
  signal input2_mux3 : Std_Logic_Vector (31 downto 0);  
  
  signal output_mux3 : Std_Logic_Vector (31 downto 0);        
  signal mux3_cmd : Std_Logic;
  
  --  *** declaration shift
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

  signal alu_vss : bit;
  signal alu_vdd : bit;

  -- *** declaration fifo
  signal fifo_din : Std_Logic_Vector (71 downto 0);

  signal fifo_push : Std_Logic;     
  signal fifo_pop  : Std_Logic;     
  signal fifo_full : Std_Logic;     
  signal fifo_empty : Std_Logic;     
  signal fifo_reset_n : Std_Logic;
  
  --  ***declaration unknown
  signal unknown_inputLW : Std_Logic;
  signal unknown_inputLB : Std_logic;
  signal unknown_inputSW : Std_logic;
  signal unknown_inputSB : Std_logic;

  signal unknown_inputDATA : Std_Logic_Vector (31 downto 0);
  signal unknown_inputDEST : Std_Logic_Vector (3 downto 0);
  signal unknown_inputMUX3 : Std_Logic_Vector (31 downto 0);      
  
  signal unknown_D2E_empty : Std_Logic;
  signal unknown_D2E_pop : Std_Logic;

  signal unknown_fifo_din : Std_Logic_Vector (71 downto 0);
  signal unknown_fifo_push: Std_logic ;
  signal unknown_fifo_full : Std_Logic;
  signal unknown_fifo_ck : Std_Logic;   

  
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
      res => alu_res,
      vdd => alu_vdd,
      vss => alu_vss
      );

-- Instanciation fifo
  fifo_0: fifo
    port map (
      din => fifo_din,
      push => fifo_push,
      pop => fifo_pop,
      full => fifo_full,
      empty  => fifo_empty,
      ck => ck,
      vss => vss,
      vdd => vdd,
      reset_n => fifo_reset_n
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
      inputMUX3 => unknown_inputMUX3,
      
      D2E_empty => unknown_D2E_empty,
      D2E_pop => unknown_D2E_pop,

      
      fifo_din => unknown_fifo_din,
      fifo_push => unknown_fifo_push,
      fifo_full => fifo_full,
      ck => ck
      );

  ---- decription du comportement
  ---- qui est relié à qui

  -- ce qui va dans le shift
  shift_input <= dec_op2;
  shift_dec_cy <= dec_cy;
  shift_lsl <= dec_shift_lsl;
  shift_lsr <= dec_shift_lsr;
  shift_asr <= dec_shift_asr;
  shift_ror <= dec_shift_ror;
  shift_rrx <= dec_shift_rrx;
  shift_val <= dec_shift_val;
  
  --ce qui va dans mux1    
  input1_mux1 <= shift_output;
  input2_mux1 <= not shift_output;
  mux1_cmd <= dec_comp_op2;
  
  --ce qui va dans mux 2
  input1_mux2 <= dec_op1;
  input2_mux2 <= not dec_op1;     
  mux2_cmd <= dec_comp_op1;

  --ce qui va dans alu
  alu_op1 <= output_mux1;
  alu_op2 <= output_mux2; 
  alu_cmd_add <= dec_alu_add;
  alu_cmd_and <= dec_alu_and;
  alu_cmd_or  <= dec_alu_or;
  alu_cmd_xor <= dec_alu_xor;
  
  alu_cin <= dec_alu_cy;

  alu_vdd <= vdd;
  alu_vss <= vss;
  
  -- ce qui va dans mux 3
  input1_mux3 <= alu_res;
  input2_mux3 <= output_mux2;
  mux3_cmd <= dec_PI;
  
  -- ce qui va dans unknown
  unknown_fifo_full <= fifo_full;
  unknown_D2E_empty <= dec2exe_empty;

  unknown_inputSB <= dec_mem_sb;
  unknown_inputSW <= dec_mem_sw;
  unknown_inputLB <= dec_mem_sb;
  unknown_inputLW <= dec_mem_lw;

  unknown_inputDATA <= dec_mem_data;
  unknown_inputDEST <= dec_mem_dest;
  unknown_inputMUX3 <= output_mux3;
  
  -- ce qui va dans fifo
  fifo_push <= unknown_fifo_push;
  fifo_din  <= unknown_fifo_din;

  -- reset clk et autre pas mis non plus...
  
  -- ce qui sort de exe
  
  exe_pop <= unknown_D2E_pop;     
  
-- bypass
  exe_res <= output_mux3;

  --flags
  exe_c <= alu_cout;
  exe_v <= alu_v;
  exe_n <= alu_n;
  exe_z <= alu_z;


  -- mettre la sortie de fifo dans comme entrée pour la sortie de exe ?
  -- write back
  exe_dest <= dec_exe_dest; --rd destination
  exe_wb <= dec_exe_wb; --rd destination wb
  exe_flag_wb <= dec_flag_wb; -- CSPR modify

  -- mem interface
  --res alu
  exe_mem_adr <= output_mux3; --alu res register

    --transfert commande
  exe_mem_data <= dec_mem_data;  
  exe_mem_dest <= dec_mem_dest;         

  exe_mem_lw <= dec_mem_lw;
  exe_mem_lb <= dec_mem_lb;   
  exe_mem_sw <= dec_mem_sw;
  exe_mem_sb <= dec_mem_sb;

  exe2mem_empty <= fifo_empty;

    
-- FIN

end Behavior;
