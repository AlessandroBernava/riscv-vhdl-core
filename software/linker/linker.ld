


ENTRY(_start)

MEMORY  {
    /* 4 KiB per il codice: 0x00000000 - 0x00000FFF */
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K

    /* 4 KiB per i dati: 0x00001000 - 0x00001FFF */
    RAM (rwx) : ORIGIN = 0x00001000, LENGTH = 4K
}

SECTIONS    {
    /* codice e costanti in ROM */
    .text : {
        *(.text.init) /* prende la routine di bootstrap */
        *(.text*)    /* prende tutti i frammenti di sezione il cui nome inizia con .text (tutto il codice) dagli object file e li concatena in    questa sezione di output  */
        *(.rodata*) /* mette tutte le costanti in ROM */
    } > ROM

     /*. = ORIGIN(RAM) + 0x100;  riserva 256 byte a out */

    .out (NOLOAD) : {
        __out_start__ = .;
        . = . + 0x100 ;      /* 256 byte: 64 word */
        __out_end__ = .;
    } > RAM
    /* dati inizializzati in RAM */
    .data :  {
        __data_start__ = .;
        *(.data*)

        *(.sdata*)
        __data_end__ = .;
    } > RAM AT> ROM

    /* Simbolo per il LMA (ROM) della sezione .data */
    __data_rom_start__ = LOADADDR(.data);

    /* dati non inizializzati (bss) in RAM */
    .bss : {
        __bss_start__ = .;
        *(.bss*)

        *(COMMON)         /* variabili globali non inizializzate messe in un'area separata per gestire definizioni multiple */
        __bss_end__ = .;
    } > RAM



    . = ALIGN(16); /*    . avanza al prossimo indirizzo multiplo di 8 (inserendo padding) per assicurarsi che la prossima sezione sia allineata a 16 byte (richiesto per sp da standard ABI per RISC V) */
    __StackLimit = .;
    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
    __end = .;

    ASSERT(__StackLimit <= __StackTop, "RAM overflow: data/bss overlap stack")

}
