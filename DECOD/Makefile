GHDL=ghdl
all : reg_tb decod

# compil fifo
reg.o : reg.vhdl
	${GHDL} -a -v reg.vhdl

reg_tb.o : reg_tb.vhdl reg.o
	${GHDL} -a -v reg_tb.vhdl 

reg_tb : reg_tb.o
	${GHDL} -e -v reg_tb
	${GHDL} -r reg_tb --vcd=reg.vcd

decod.o :  decod.vhdl
	${GHDL} -a -v decod.vhdl 

decod : decod.o
#	${GHDL} -e -v decod_tb
#	${GHDL} -r decod_tb --vcd=decod.vcd



clean :
	rm *.o *#  *vcd *~ work-obj93.cf reg_tb decod_tb 
