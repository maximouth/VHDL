LIBRARY ieee;
use ieee.std_logic_1164.all;
--use IEEE.numeric_std.all;



ENTITY fifo IS
  generic(WIDTH: positive);
  PORT(
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
END fifo;

architecture dataflow of fifo is

  signal fifo_d	: std_logic_vector(WIDTH-1 downto 0);
  signal fifo_v	: std_logic;

begin

  process(ck)
    
  begin
    if rising_edge(ck) then
      -- Valid bit
      if reset_n = '0' then
        fifo_v <= '0';
      else
        if fifo_v = '0' then
          if push = '1' then
            fifo_v <= '1';
            fifo_d <= din;
          else
            fifo_v <= '0';
          end if;
        else
          if pop = '1' then
            if push = '1' then
              fifo_v <= '1';
              fifo_d <= din;
            else
              fifo_v <= '0';
            end if;
          else
            fifo_v <= '1';
          end if;
        end if;
      end if;

    end if;

    -- report "---------*********---------";
    -- report "width :" & integer'image (width);
    -- report "ck :" & std_logic'image (ck);
    -- report "fifo_v :" & std_logic'image (fifo_v);
    -- report "push :" & std_logic'image (push);
    -- report "pop :" & std_logic'image (pop);
    -- report "reset_n :" & std_logic'image (reset_n);
    -- report "din 31 :" & std_logic'image (din(31));
    -- report "din 30 :" & std_logic'image (din(30));
    -- report "dout31 :" & std_logic'image (fifo_d(31));
    -- report "dout30 :" & std_logic'image (fifo_d(30));
    -- report "full :" & std_logic'image (full);
    -- report "empty :" & std_logic'image (empty);
  end process;

  -- There is only one cell in th FIFO, so it cannot be non-full and non-empty
  -- at the same time
  full  <= fifo_v;
  empty <= not fifo_v;
  -- always pop, the validity of the value depends on signals full/empty
  dout  <= fifo_d;

end dataflow;
