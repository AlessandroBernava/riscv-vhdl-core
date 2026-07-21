WORKDIR = obj
SIMDIR = simu

GHDL = ghdl
GTKWAVE = gtkwave
GHDLFLAGS = --std=08 --workdir=$(WORKDIR)

TOP_TB = tb_rv32i_core
STOP_TIME = 30us
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

analizza: $(WORKDIR) | mem
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
	rm -rf $(WORKDIR) $(SIMDIR) $(SOFT_BUILD_DIR)

# Sezione software: compilazione C -> ELF -> file memorie

# Nome di default del programma C (main.c)

APP ?= main# Sovrascrive main se app non è definita da nessuna parte, con make APP=... oppure definendo APP in un punto del makefile main non viene sovrascritto

# Toolchain GNU RISC V

CC := riscv-none-elf-gcc
OBJDUMP := riscv-none-elf-objdump
READELF := riscv-none-elf-readelf
NM := riscv-none-elf-nm

# Cartelle

SOFT_SRC_DIR := software/src
SOFT_BUILD_DIR := software/build
SOFT_LINKER := software/linker/linker.ld
SOFT_SCRIPT_INSTR := software/scripts/hex_generator.py
SOFT_SCRIPT_DATA := software/scripts/data_mem_hex_generator.py

CFLAGS := -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -O0 -Wall -Wextra -mno-relax
LDFLAGS := -T $(SOFT_LINKER) -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -Wl,--no-relax

# Sorgenti

SOFT_ASM_SRC := $(SOFT_SRC_DIR)/start.S
SOFT_C_SRC := $(SOFT_SRC_DIR)/$(APP).c

SOFT_START_O := $(SOFT_BUILD_DIR)/start.o
SOFT_APP_O := $(SOFT_BUILD_DIR)/$(APP).o
SOFT_ELF := $(SOFT_BUILD_DIR)/$(APP).elf
SOFT_DUMP := $(SOFT_BUILD_DIR)/$(APP).dump
SOFT_SECTIONS := $(SOFT_BUILD_DIR)/$(APP).sections
SOFT_SYMS := $(SOFT_BUILD_DIR)/$(APP).symbols

soft_dirs:                 # La directroy build viene eliminata con make clear
	mkdir -p $(SOFT_BUILD_DIR)

$(SOFT_START_O): $(SOFT_ASM_SRC) | soft_dirs     # $< = primo prerequisito $@ = target $^ = tutte le dipendenze
	$(CC) -c $< -o $@ $(CFLAGS)

$(SOFT_APP_O): $(SOFT_C_SRC) | soft_dirs
	$(CC) -c $< -o $@ $(CFLAGS)

$(SOFT_ELF): $(SOFT_START_O) $(SOFT_APP_O)
	$(CC) -o $@ $^ $(LDFLAGS)

.PHONY: elf

elf: $(SOFT_ELF)

dump: $(SOFT_ELF)
	$(OBJDUMP) -D $(SOFT_ELF) > $(SOFT_DUMP)
	$(READELF) -S $(SOFT_ELF) > $(SOFT_SECTIONS)
	$(NM) -n $(SOFT_ELF) > $(SOFT_SYMS)

mem: $(SOFT_ELF) | dump
	python $(SOFT_SCRIPT_INSTR) $(SOFT_ELF) | python $(SOFT_SCRIPT_DATA) $(SOFT_ELF)

check-app:
	@echo "APP = '$(APP)'"
	@echo "origin(APP) = $(origin APP)"

help:
	@echo "Target make disponibili:"
	@echo "  make / make simula       - analizza, elabora e simula il testbench"
	@echo "                             usa di default APP=main (main.c)"
	@echo "                             es: make APP=test1 simula"
	@echo "                             -> usa software/src/test1.c al posto di main.c"
	@echo "  make onda                - genera waveform (.ghw) per GTKWave"
	@echo "  make guarda / wave       - apre GTKWave sulla waveform"
	@echo "  make analizza            - analizza tutti i file VHDL"
	@echo "  make elabora             - elabora il testbench top"
	@echo "  make elf                 - produce l'eseguibile ELF del programma C"
	@echo "  make dump                - genera dump, sezioni e simboli dell'ELF"
	@echo "  make mem                 - genera i file di inizializzazione per le"
	@echo "                             memorie istruzioni/dati a partire dall'ELF"
	@echo "  make clean               - pulisce obj/, simu e build/"
