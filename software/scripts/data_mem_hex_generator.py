import sys
from elftools.elf.elffile import ELFFile

if len(sys.argv) < 2:
    print("Uso: python data_mem_generator.py <file.elf> [output.mem]")
    sys.exit(1)

elf_path = sys.argv[1]
out_path = sys.argv[2] if len(sys.argv) >= 3 else "software/build/data.mem"   # Attualmente non passiamo l'output file

DATA_BASE = 0x00001100
DATA_SIZE = 1024 * 4

with open(elf_path, "rb") as f:
    elf = ELFFile(f)

    mem = bytearray(DATA_SIZE)

    for sec in elf.iter_sections():
        if sec.name in (".data", ".sdata"):
            addr = sec["sh_addr"]
            data = sec.data()

            start = addr - DATA_BASE
            end = start + len(data)

            if start < 0 or end > DATA_SIZE:
                raise ValueError(
                    f"Sezione {sec.name} fuori range data memory: "
                    f"addr=0x{addr:08X}, size={len(data)}, "
                    f"DATA_BASE=0x{DATA_BASE:08X}, DATA_SIZE={DATA_SIZE}"
                )

            mem[start:end] = data

with open(out_path, "w") as out:
    for i in range(0, len(mem), 4):
        word_bytes = mem[i:i+4]
        word = int.from_bytes(word_bytes, byteorder="little")
        out.write(f"{word:08X}\n")


