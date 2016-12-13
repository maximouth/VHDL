library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
  port(
    -- Write Port 1 prioritaire
    wdata1		: in Std_Logic_Vector(31 downto 0);
    wadr1			: in Std_Logic_Vector(3 downto 0);
    wen1			: in Std_Logic;

    -- Write Port 2 non prioritaire
    wdata2		: in Std_Logic_Vector(31 downto 0);
    wadr2			: in Std_Logic_Vector(3 downto 0);
    wen2			: in Std_Logic;

    -- Write CSPR Port
    wcry			: in Std_Logic;
    wzero			: in Std_Logic;
    wneg			: in Std_Logic;
    wovr			: in Std_Logic;
    cspr_wb		: in Std_Logic;
    
    -- Read Port 1 32 bits
    rdata1		: out Std_Logic_Vector(31 downto 0);
    radr1			: in Std_Logic_Vector(3 downto 0);
    rvalid1		: out Std_Logic;

    -- Read Port 2 32 bits
    rdata2		: out Std_Logic_Vector(31 downto 0);
    radr2			: in Std_Logic_Vector(3 downto 0);
    rvalid2		: out Std_Logic;

    -- Read Port 3 5 bits (for shift)
    rdata3		: out Std_Logic_Vector(31 downto 0);
    radr3			: in Std_Logic_Vector(3 downto 0);
    rvalid3		: out Std_Logic;

    -- read CSPR Port
    cry			: out Std_Logic;
    zero			: out Std_Logic;
    neg			: out Std_Logic;
    ovr			: out Std_Logic;
    
    -- Invalidate Port 
    inval_adr1	: in Std_Logic_Vector(3 downto 0);
    inval1		: in Std_Logic;

    inval_adr2	: in Std_Logic_Vector(3 downto 0);
    inval2		: in Std_Logic;

    inval_czn	: in Std_Logic;
    inval_ovr	: in Std_Logic;

    -- PC
    reg_pc		: out Std_Logic_Vector(31 downto 0);
    reg_pcv		: out Std_Logic;
    inc_pc		: in Std_Logic;
    
    -- global interface
    ck					: in Std_Logic;
    reset_n			: in Std_Logic;
    vdd				: in bit;
    vss				: in bit);
end Reg;

architecture Behavior OF Reg is

-- RF 
  type rf_array is array(15 downto 0) of std_logic_vector(31 downto 0);
  signal r_reg	: rf_array;

  signal r_valid : Std_Logic_Vector(15 downto 0);
  signal r_c		: Std_Logic;
  signal r_z		: Std_Logic;
  signal r_n		: Std_Logic;
  signal r_v		: Std_Logic;
  signal r_cznv	: Std_Logic;
  signal r_vv		: Std_Logic;

begin

  process (ck)
  begin
    if rising_edge(ck) then
      if reset_n = '0' then
        r_valid <= X"FFFF";
      end if;

    end if;
  end process;

-- read registers ports

-- read CSPR Port

end Behavior;
