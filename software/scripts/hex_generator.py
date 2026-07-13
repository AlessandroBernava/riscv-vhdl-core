import sys
from elftools.elf.elffile import ELFFile

if len(sys.argv) < 2:
    print("Uso: python hex_generator.py <file.elf>")
    sys.exit(1)

elf_path = sys.argv[1]

INST_BASE = 0x0000000
INST_SIZE = 1024 * 4

with open(elf_path, "rb") as f:
    elf = ELFFile(f)

    mem = bytearray(INST_SIZE)

    for sec in elf.iter_sections():
        if sec.name.startswith(".text") or sec.name.startswith(".rodata"):
            addr = sec["sh_addr"]           # legge il campo sh addr dell'header ELF della sezione (indirizzo virtuale deciso dal linker in cui deve essere caricata la sezione)
            data = sec.data() # Data: oggetto bytes con i dati della sezione

            start = addr - INST_BASE  # Per quando servira' inizializzare anche la data memory
            end = start + len(data)

            mem[start:end] = data # Copia i byte di data nell'array mem

with open("software/build/instr.mem", "w") as out:
    for i in range(0, len(mem), 4):
        word_bytes = mem[i:i+4]
        word = int.from_bytes(word_bytes, byteorder="little")
        out.write(f"{word:08X}\n")   # 08X = esadecimale 8 cifre riempi con 0 davanti
