#FILE= addaccu.vhdl
#FILE_TEST = addaccu_tb.vhdl
#FILE2 = addaccu_tb

FILE= alu.vhdl
FILE_TEST = alu_tb.vhdl
FILE2 = alu_tb

CC= ghdl

ghdl_all :
	$(CC) -a -v $(FILE)
	$(CC) -a -v $(FILE_TEST)
	$(CC) -e -v $(FILE2)
	$(CC) -r $(FILE2) --vcd=$(FILE2).vcd	


ghdl_compile :
	$(CC) -a -v $(FILE)

ghdl_test :
	$(CC) -a -v $(FILE_TEST)
	$(CC) -e -v $(FILE2)
	$(CC) -r $(FILE2) --vcd=$(FILE2).vcd	



clean :
	rm *~ *.o *.cf *.vcd $(FILE2) *#
