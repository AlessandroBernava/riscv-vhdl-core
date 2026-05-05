WORKDIR = obj
SRC = src/core/alu.vhd src/core/register_file.vhd #esempio
TB = tb/tb_alu.vhd
TOP_TB = tb_alu

simula: analizza
	ghdl -m --workdir=$(WORKDIR) $(TOP_TB)
	ghdl -r --workdir=$(WORKDIR) $(TOP_TB) --wave=$(WORKDIR)/onda.ghw

analizza:
	ghdl -a --workdir=$(WORKDIR) $(SRC) $(TB)

guarda:
	gtkwave $(WORKDIR)/onda.ghw
