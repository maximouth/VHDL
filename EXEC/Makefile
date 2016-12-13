GHDL=ghdl
all : fifo_tb shift_tb mux_tb alu_tb  exec_tb

# compil fifo
fifo_generic.o : fifo_generic.vhdl
	${GHDL} -a -v fifo_generic.vhdl

fifo_tb.o : fifo_tb.vhdl fifo_generic.o
	${GHDL} -a -v fifo_tb.vhdl 

fifo_tb : fifo_tb.o
	${GHDL} -e -v fifo_tb
	${GHDL} -r fifo_tb --vcd=fifo.vcd

# compil shift
shift.o : shift.vhdl
	${GHDL} -a -v shift.vhdl

shift_tb.o : shift_tb.vhdl shift.o
	${GHDL} -a -v shift_tb.vhdl 

shift_tb : shift_tb.o
	${GHDL} -e -v shift_tb
	${GHDL} -r shift_tb --vcd=shift.vcd

# compil mux
mux.o : mux.vhdl
	${GHDL} -a -v mux.vhdl

mux_tb.o : mux_tb.vhdl mux.o
	${GHDL} -a -v mux_tb.vhdl 

mux_tb : mux_tb.o
	${GHDL} -e -v mux_tb
	${GHDL} -r mux_tb --vcd=mux.vcd

# compil alu
alu.o : alu.vhdl
	${GHDL} -a -v alu.vhdl

alu_tb.o : alu_tb.vhdl alu.o
	${GHDL} -a -v alu_tb.vhdl 

alu_tb : alu_tb.o
	${GHDL} -e -v alu_tb
	${GHDL} -r alu_tb --vcd=alu.vcd

# compil unknown
unknown.o : unknown.vhdl
	${GHDL} -a -v unknown.vhdl

unknown_tb.o : unknown_tb.vhdl unknown.o
	${GHDL} -a -v unknown_tb.vhdl 

unknown_tb : unknown_tb.o
	${GHDL} -e -v unknown_tb
	${GHDL} -r unknown_tb --vcd=unknown.vcd

# compil exec
exec.o : exec.vhdl
	${GHDL} -a -v exec.vhdl

exec_tb.o : exec_tb.vhdl alu.o mux.o fifo_generic.o unknown.o shift.o exec.o
	${GHDL} -a -v exec_tb.vhdl 

exec_tb : exec_tb.o
	${GHDL} -e -v exec_tb
	${GHDL} -r exec_tb --vcd=exec.vcd



clean :
	rm *.o *#  *vcd *~ work-obj93.cf alu_tb mux_tb fifo_tb exec_tb unknown_tb shift_tb
