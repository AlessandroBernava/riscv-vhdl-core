WORKDIR = obj
SIMDIR = simu

GHDL = ghdl
GTKWAVE = gtkwave
GHDLFLAGS = --std=08 --workdir=$(WORKDIR)

TOP_TB = tb_rv32i_core
STOP_TIME = 1us
WAVEFILE = $(SIMDIR)/$(TOP_TB).ghw

PKG = \
	src/core/pkg_riskv_types.vhd \
	src/core/pkg_riskv_pipeline.vhd

CORE = \
	src/core/program_counter.vhd \
	src/core/instruction_memory.vhd \
	src/core/register_file.vhd \
	src/core/immediate_generator.vhd \
	src/core/alu_ctrl.vhd \
	src/core/alu.vhd \
	src/core/branch_jump_unit.vhd \
	src/core/load_unit.vhd \
	src/core/store_unit.vhd \
	src/core/control_unit.vhd \
	src/core/forwarding_unit.vhd \
	src/core/hazard_detection_unit.vhd \
	src/core/data_memory.vhd \
	src/core/rv32i_core.vhd

TB = \
	tb/tb_rv32i_core.vhd

SRC = $(PKG) $(CORE) $(TB)

all: simula

$(WORKDIR):
	mkdir -p $(WORKDIR)

$(SIMDIR):
	mkdir -p $(SIMDIR)

analizza: $(WORKDIR)
	$(GHDL) -a $(GHDLFLAGS) $(SRC)

elabora: analizza
	$(GHDL) -e $(GHDLFLAGS) $(TOP_TB)

simula: elabora
	$(GHDL) -r $(GHDLFLAGS) $(TOP_TB) --stop-time=$(STOP_TIME)

onda: elabora $(SIMDIR)
	$(GHDL) -r $(GHDLFLAGS) $(TOP_TB) --stop-time=$(STOP_TIME) --wave=$(WAVEFILE)

guarda: onda
	$(GTKWAVE) $(WAVEFILE)

wave: guarda

clean:
	rm -rf $(WORKDIR) $(SIMDIR)
