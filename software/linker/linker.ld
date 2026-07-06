
ENTRY(_start)

MEMORY  {
    /* 4 KiB per il codice: 0x00000000 - 0x00000FFF */
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K

    /* 4 KiB per i dati: 0x00001000 - 0x00001FFF */
    RAM (rwx) : ORIGIN = 0x00001000, LENGTH = 4K
}

SECTIONS    {

}

