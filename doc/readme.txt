
 PROGETTO CORE RISC-V RV32I

Questo progetto contiene il design di una CPU RISC-V (RV32I) in VHDL e un flusso di lavoro automatizzato tramite Makefile.
Il Makefile si occupa di compilare il codice C/Assembly, estrarre i dati dall'eseguibile ELF, inizializzare le memorie del processore e avviare la simulazione hardware.

CLONARE LA REPOSITORY DA GITHUB
Il progetto è disponibile su GitHub:

https://github.com/AlessandroBernava/riscv-vhdl-core

Per ottenere una copia locale, aprire un terminale nella directory in cui si desidera scaricare il progetto ed eseguire:

git clone https://github.com/AlessandroBernava/riscv-vhdl-core.git

Git crea automaticamente una cartella chiamata riscv-vhdl-core. Per entrare nella repository:

cd riscv-vhdl-core

È possibile scegliere un nome diverso per la cartella locale aggiungendolo alla fine del comando. Ad esempio:

git clone https://github.com/AlessandroBernava/riscv-vhdl-core.git mio_progetto
cd mio_progetto

Il nome della cartella locale non modifica il funzionamento degli script. È però necessario scegliere un percorso senza spazi, preferibilmente breve, per evitare problemi con gli strumenti del flusso FPGA.

Il clone contiene i file versionati presenti su GitHub. I file generati dalla compilazione e il progetto Vivado vengono ricreati localmente tramite Makefile e script.

FLUSSO FPGA CON VIVADO
Il flusso FPGA è stato verificato su Windows con AMD Vivado 2026.1.

Il Makefile genera le immagini delle memorie a partire dal programma selezionato e avvia Vivado in modalità batch. Lo script fpga/scripts/create_project.tcl crea il progetto, aggiunge i sorgenti VHDL, il testbench, i vincoli XDC, le immagini delle memorie e le configurazioni delle IP Clocking Wizard e ILA.

La creazione del progetto non avvia automaticamente simulazione, sintesi o implementazione. Queste operazioni vengono eseguite successivamente dalla GUI di Vivado.

Tutti i comandi seguenti devono essere eseguiti dalla radice della repository, cioè dalla cartella che contiene il Makefile.

PREPARAZIONE DELL'AMBIENTE VIVADO CON POWERSHELL
Prima di eseguire la build è necessario rendere Vivado raggiungibile dal terminale.

Aprire fpga/scripts/env_vivado.ps1 e verificare che il percorso della directory bin corrisponda alla propria installazione di Vivado. Il percorso presente nello script è un'impostazione locale da adattare al proprio PC.

Dalla radice della repository, eseguire:

.\fpga\scripts\env_vivado.ps1

Lo script aggiunge la directory degli eseguibili Vivado al PATH della sessione PowerShell corrente. La preparazione va ripetuta quando si apre una nuova sessione.

Per verificare che Vivado sia raggiungibile:

where.exe vivado

Il comando deve restituire il percorso di vivado.bat.

UTILIZZO CON CMD
In alternativa a PowerShell, è possibile utilizzare il Prompt dei comandi (CMD).

In questo caso, preparare l'ambiente eseguendo settings64.bat dalla propria installazione Vivado. Ad esempio:

call "D:\AMDDesignTools\2026.1\Vivado\settings64.bat"

Adattare il percorso alla propria installazione e verificare:

where vivado

La preparazione dell'ambiente e i successivi comandi Make devono essere eseguiti nella stessa sessione CMD.

CREAZIONE DEL PROGETTO VIVADO
Dopo aver preparato l'ambiente, eseguire:

make APP=FPGA_led_test vivado_project

Il parametro APP seleziona il programma presente in software/src/, senza indicare l'estensione .c.

Il comando aggiorna il software secondo le dipendenze del Makefile, genera instr.mem e data.mem e crea il progetto Vivado in:

fpga/build/rv32i_nexys/rv32i_nexys.xpr

I log della creazione vengono salvati in:

fpga/build/logs/

Per protezione, lo script non sovrascrive una directory di progetto già esistente. Se si desidera ricrearlo, chiudere il progetto in Vivado ed eseguire:

make clean_vivado

Quindi rilanciare:

make APP=FPGA_led_test vivado_project

APERTURA DEL PROGETTO VIVADO
Dopo la creazione del progetto, aprirlo con:

make vivado_open

Questo comando equivale a:

vivado "fpga/build/rv32i_nexys/rv32i_nexys.xpr"

È possibile anche aprire Vivado manualmente e selezionare il file .xpr tramite Open Project.

SIMULAZIONE RTL IN VIVADO
Il Flow Navigator è il pannello della GUI di Vivado che raccoglie le principali operazioni del progetto. I percorsi seguenti indicano voci dell'interfaccia, non comandi da digitare nel terminale.

Per avviare la simulazione comportamentale:

Flow Navigator → SIMULATION → Run Simulation → Run Behavioral Simulation

Il top di simulazione è tb_fpga_top, mentre il top hardware è fpga_top.

Verificare l'assenza di errori di compilazione, elaborazione e apertura delle memorie, quindi controllare che il testbench raggiunga il risultato previsto.

SINTESI, IMPLEMENTAZIONE E BITSTREAM
Dopo la verifica della simulazione, eseguire nell'ordine:

Flow Navigator → SYNTHESIS → Run Synthesis
Flow Navigator → IMPLEMENTATION → Run Implementation
Flow Navigator → PROGRAM AND DEBUG → Generate Bitstream

Prima di utilizzare il bitstream, controllare i report di timing, utilizzo delle risorse e gli eventuali errori o warning rilevanti.

Il bitstream viene generato nella directory:

fpga/build/rv32i_nexys/rv32i_nexys.runs/impl_1/

PROGRAMMAZIONE DELLA FPGA
Collegare la Nexys tramite la porta micro-USB etichettata PROG, alimentarla e aprire:

Flow Navigator → PROGRAM AND DEBUG → Open Hardware Manager
Open target → Auto Connect
Right-click sul device → Program Device

Selezionare il bitstream generato in:

fpga/build/rv32i_nexys/rv32i_nexys.runs/impl_1/

e premere Program.

La programmazione JTAG è volatile: dopo lo spegnimento della board, la FPGA torna vuota finché non viene riprogrammata.

FILE SORGENTE E FILE GENERATI
I sorgenti VHDL, i vincoli XDC, le configurazioni IP e gli script sono mantenuti nella repository.

Le directory software/build/ e fpga/build/ contengono output generati e non devono essere versionate.

Le modifiche a un file VHDL già registrato non richiedono di aggiungerlo nuovamente al progetto. L'aggiunta di nuovi file, nuove IP o modifiche alle impostazioni del progetto richiede invece di aggiornare la relativa descrizione negli script, così che il progetto possa essere ricostruito.

 AMBIENTE DI SVILUPPO E TOOLCHAIN

Il progetto è stato sviluppato e testato su Windows in Visual Studio Code, utlizzato come editor per la scrittura del codice VHDL, programmi in C, script Python e codice assembly.
L'ambiente  è composto da una toolchain software costituita da:
    - un cross compiler GCC
    - un linker script che definisce la mappa di memoria del sistema
    - script Python che elaborano i file ELF generati dalla toolchain e producono le immagini di memoria utilizzate in simulazione per inizializzare instruction e data memory
    - un simulatore VHDL (GHDL) per la verifica ed esecuzione del modello hardware della CPU
    - un Makefile che gestisce l'intero flusso: compilazione del software, linking, esecuzione degli script per la generazione delle memorie, analisi dei moduli hardware, e avvio della simulazione
I comandi Make sono eseguiti da terminale (PowerShell su Windows).

UTILIZZO DEL MAKEFILE

Di default, il Makefile, tramite comando make prenderà il file 'software/src/main.c' per compilarlo e caricarlo sulla CPU.

Comandi principali:

- make (oppure 'make simula')
    Compila main.c, genera l'ELF, crea i file .mem per le memorie, analizza/elabora i file VHDL e simula il testbench.

- make APP=nome simula
    Fa lo stesso di make, ma invece di main.c usa il file nome.c (situato sempre in software/src/). In pratica, 'APP=nome'  permette di scegliere quale programma (presente in src/) far girare sulla CPU senza dover modificare il Makefile.

- make onda
    Come 'simula', ma alla fine genera anche il file .ghw con le forme d'onda da poter ispezionare.

- make guarda
    Apre in automatico GTKWave caricando l'ultima simulazione effettuata.

- make clean
    Pulisce l'ambiente eliminando le cartelle generate (obj/, simu/ e software/build/).

Comandi intermedi (per eseguire solo alcune fasi)
- make analizza : analizza i file VHDL (core, testbench, package)
- make elabora  : costruisce la gerarchia di simulazione per il testbench
- make elf      : compila il programma C in un eseguibile ELF
- make dump     : genera file di testo con il dump dell'assembly e delle sezioni
- make mem      : lancia gli script Python per generare l'hex delle memorie

STRUMENTI NECESSARI

Per far funzionare il tutto, è necessario avere installati i seguenti programmi:

1. GNU Make
2. GHDL (con supporto per VHDL-2008)
3. GTKWave (per visualizzare le forme d'onda)
4. Toolchain GNU RISC-V:
   - riscv-none-elf-gcc
   - riscv-none-elf-objdump
   - riscv-none-elf-readelf
   - riscv-none-elf-nm
   (Nota: strumenti inclusi nella toolchain "xPack GNU RISC-V Embedded GCC")
5. Python 3
6. pyelftools: libreria Python che serve agli script per leggere i file ELF. Installabile con: pip install pyelftools

ARCHITETTURA DELLA CPU E SCELTE PROGETTUALI

Il processore è stato realizzato secondo la specifica RISC-V RV32I (32-bit), scritto in VHDL e pensato per essere implementato come softcore su FPGA. E' stato implementato con una pipeline a 5 stadi (Fetch, Decode, Execute, Memory, Writeback).

Principali scelte architetturali:

    - Memorie sincrone e inferenza delle BRAM: Sia l'Instruction Memory che la Data Memory sono implementate con lettura sincrona. Questa scelta permette agli strumenti di sintesi di mapparle direttamente su blocchi BRAM (Block RAM) delle FPGA, evitando il consumo eccessivo di LUT. Data la latenza di un ciclo delle memorie sincrone, queste assorbono implicitamente le funzioni dei registri di pipeline adiacenti (l'Instruction Memory funge da registro IF/ID; la lettura della Data Memory sostituisce parte del registro MEM/WB).

    - Register file a 2 letture / 1 scrittura: il register file (32 registri  x 32 bit) è implementato come array di flip-flop con due porte di lettura asincrone e una porta di scrittura sincrona, quindi viene mappato dagli strumenti di sintesi su logica LUT/FF e non su BRAM (più adatta a memorie grandi). Questo schema è quello classico per il register file di una pipeline RISC: in ID gli operandi rs1/rs2 sono immediatamente disponibili, mentre in WB la scrittura avviene sul fronte di clock.

    - Forwarding interno nel register file: Per evitare che una lettura in ID veda un valore vecchio quando nello stesso ciclo lo stadio WB scrive sullo stesso registro, il register file integra un meccanismo di internal forwarding: se we='1' e rd_addr_i coincide con rs1_addr_i o rs2_addr_i, le uscite rs1_data_o/rs2_data_o propagano direttamente write_data_i invece del contenuto di reg. In questo modo il core può leggere il valore appena scritto senza inserire stall tra WB e ID, eliminando lo structural hazard di lettura/scrittura sullo stesso registro nello stesso ciclo.

    - Gestione del reset nel register file: Il reset è puramente sincrono, azzera infatti l’intero array di registri solo nel process sincrono (sul fronte di clock) e non interviene nelle uscite combinatorie. Evitare un reset “ibrido” (sincrono sulla memoria, asincrono sulle uscite) comporta il rischio di glitch quando il segnale di reset cambia vicino al fronte del clock su FPGA, rendendo il valore prodotto sulle uscite metastabile. La responsabilità di mantenere we='0' durante il reset è quindi delegata al controller della pipeline (Control Unit), e i registri di pipeline (es. ID/EX) vengono azzerati, impedendo la propagazione di eventuali valori spuri. Questa scelta rende il comportamento del register file più deterministico e adatto alla sintesi su FPGA.

    - Hazard Unit e Forwarding: Il core implementa un sistema completo di data forwarding (da EX/MEM e MEM/WB verso lo stadio EX) per risolvere gli hazard RAW senza inserire stalli. La Hazard Detection Unit interviene solo per il load-use hazard, congelando PC e Instruction Memory e inserendo una singola bolla (NOP) in ID/EX.

    - Gestione dei control hazard e jump tramite Branch Unit: la condizione di salto viene valutata in EX, usando direttamente i due operandi già forwardati e il flag zero della ALU per BEQ/BNE, oppure confronti signed/unsigned per BLT/BGE/BLTU/BGEU, mentre JAL/JALR saltano sempre. Lo schema di branch prediction è 'always not taken' (più semplice schema di static branch prediction): la pipeline continua a fetchare e decodificare normalmente fino a quando la branch arriva in EX; in quel ciclo, se jump_o='1', il core aggiorna il PC al target e inserisce un flush su Instruction Memory e su ID/EX, trasformando  le due istruzioni già entrate dopo la branch.
    Il costo del control hazard è quindi di 2 cicli “persi” per ogni branch taken: uno per l’istruzione in IF e uno per quella in ID che vengono annullate quando il salto viene rilevato in EX, mentre le istruzioni già in EX/MEM e MEM/WB proseguono normalmente.

    - ALU Control ottimizzato: La Control Unit delega la generazione del codice operativo interno all'ALU Decoder. Sfruttando la codifica nativa dell'ISA RISC-V (es. il bit 30 e il campo funct3 per operazioni logico/aritmetiche R/I), la logica di decodifica dell'ALU risulta estremamente compatta.

    - Load/Store Unit separate: Data la natura sincrona della BRAM, la preparazione dei dati da scrivere (con i relativi byte_enable) avviene in MEM (Store Unit), mentre la formattazione dei dati letti (selezione byte/halfword e sign-extension) avviene in WB (Load Unit). Attualmente sono supportati solo accessi di memoria allineati; quelli misallineati generano un segnale di eccezione.

PACKAGE VHDL UTILIZZATI

Per mantenere il design modulare e leggibile, la CPU usa due package principali:

- Pkg_riskv_types (tipi e costanti ISA):
Raccoglie tutti i tipi e le costanti comuni del progetto:

    - word_t: vettore a 32 bit, unità base per dati e indirizzi.
    - reg_addr_t e reg_file_t: tipo per gli indirizzi dei registri (x0–x31).
    - Tipi e costanti per la memoria (instr_mem_t, data_mem_t, dimensioni, base address dei dati).
    - Costanti per gli opcode (opc_load, opc_op, opc_branch, opc_jal, ecc.) e per i codici ALU (alu_add, alu_sub, alu_sll, …).
    - Costanti funct3 per le varie classi di istruzioni (aritmetiche, branch, load/store) e per i formati (instr_type_t = R, I, S, B, U, J).

In pratica, questo package centralizza la descrizione dell’ISA a livello hardware: tutti i moduli (Control Unit, ALU Control, Branch Unit, LSU) fanno riferimento alle stesse costanti, riducendo errori e duplicazioni.

- pkg_riskv_pipeline (registri di pipeline e reset)
Definisce la struttura dei tre registri di pipeline principali:

if_id_reg_t: contiene PC, PC+4 e l’istruzione fetchata (instr_if).

id_ex_reg_t: contiene indirizzi rs1/rs2/rd, dati (pc, pc4, rs1_data, rs2_data, imm_ext), informazioni di decodifica (f3, f7b, opcode) e tutti i segnali di controllo necessari a EX/MEM/WB (ALUOp, sorgenti A/B, mem_read/write, mem_size/unsigned, reg_write, result_src).

ex_mem_reg_t e mem_wb_reg_t: propagano i risultati dell’ALU, l’indirizzo di store/load, i segnali per la memoria e i controlli di writeback.

Il package fornisce anche le costanti di reset (ID_EX_REG_RESET, EX_MEM_REG_RESET, MEM_WB_REG_RESET), usate nei process dei registri di pipeline per inserire bolle (NOP) in modo consistente durante reset, flush e stall. Questo approccio evita di ripetere manualmente i campi azzerati in ogni modulo, garantisce che tutti i segnali di controllo siano azzerati in modo uniforme e rende più chiaro cosa “contiene” ogni stadio della pipeline e come viene resettato.

Queste astrazioni rendono il core più facile da estendere (nuovi segnali di controllo, nuovi tipi di istruzioni) e più leggibile, perché la struttura della pipeline e la codifica dell’ISA sono documentate in un unico posto, referenziato da tutti i moduli.

MAPPA DI MEMORIA E FLUSSO DI COMPILAZIONE

Il sistema adotta un approccio bare-metal, senza sistema operativo, gestito tramite un linker script personalizzato (linker.ld) e una routine di bootstrap (start.S) scritta in Assembly.

Mappa di Memoria:
Il linker script divide l'indirizzamento in due regioni principali:

ROM (0x00000000 - 0x00000FFF, 4 KiB): Contiene il codice eseguibile (.text) e le costanti a sola lettura (.rodata).

RAM (0x00001000 - 0x00001FFF, 4 KiB): Contiene le variabili globali inizializzate (.data), quelle non inizializzate (.bss), una zona riservata per eventuale memory-mapped I/O (.out) e lo Stack, che cresce dall'indirizzo più alto (__StackTop) verso il basso. Lo Stack Pointer è allineato a 16 byte come da specifica della ABI RISC-V.

Flusso di Bootstrap e Inizializzazione:

Compilazione: Il codice C viene compilato assieme al file di bootstrap start.S.

Bootstrap: Al reset, l'hardware imposta il PC a 0x00000000. Qui risiede, come stabilito dal linker script, la routine di bootstrap (_start) che si occupa di:

    - Inizializzare lo Stack Pointer (sp) alla cima della RAM.
    - Azzerare la sezione .bss.
    - Chiamare la funzione main in C.
    - In caso di uscita dal main, bloccarsi in un loop infinito di halt.

Immagini di Memoria (Simulazione vs Sintesi): Poiché il codice VHDL parte con memorie vuote, l'ELF generato viene elaborato da script Python che estraggono la sezione .text e la sezione .data. Queste vengono salvate in file formattati che il testbench legge a runtime tramite TEXTIO, pre-caricando così le memorie prima che la simulazione inizi. Questo simula il comportamento che, su FPGA hardware, si otterrebbe pre-inizializzando le BRAM tramite file di configurazione (.coe o .mif) / bitstream.

TESTBENCH E DEBUG
Il testbench fornisce un clock e un segnale di reset iniziale. Oltre a istanziare la CPU, include un monitoraggio approfondito dello stato interno del processore: ad ogni colpo di clock stampa su terminale dati quali i valori del PC, dell'istruzione in corso, i segnali di write-enable nei vari stadi, i dati in scrittura, lo stato di alcuni registri (es. x1-x17) e le prime word della RAM. L'esecuzione si interrompe automaticamente se vengono soddisfatte specifiche condizioni di terminazione o errori architetturali inseriti nei programmi di test. I principali bug rilevati durante lo sviluppo della CPU sono stati descritti in doc/debug_core.txt
