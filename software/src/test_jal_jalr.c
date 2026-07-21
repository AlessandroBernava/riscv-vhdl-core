#include <stdint.h>
typedef unsigned int u32;
#define m ((volatile u32 *)0x00001100) // versione migliore: macro: non esiste alcuna variabile m da mettere a 0x1100. m è solo una sostituzione testuale fatta dal preprocessore; il compilatore incorpora direttamente l’indirizzo 0x1100 nelle istruzioni necessarie.

// volatile u32 *m = (volatile u32 *)0x00001104; //variabile globale puntatore: se e' in data puo' creare un problema di autosovrascrittura -  se la variabile globale m (il puntatore) e l’area di memoria a cui m punta coincidono sullo stesso indirizzo. In questo modo, la prima assegnazione m[0] = ... scrive proprio nella cella che contiene il valore di m, distruggendo il puntatore

int foo(int x)
{
    m[0] = 111; // deve succedere
    return x + 7;
}

int bar(int x)
{
    m[1] = 222; // deve succedere
    return x * 2;
}

int main(void)
{
    int a, b, c;
    u32 sig = 0;

    // pulizia
    m[0] = 0;
    m[1] = 0;
    m[2] = 0;
    m[3] = 0;
    m[4] = 0;
    m[5] = 0;
    m[6] = 0;
    m[7] = 0;

    a = foo(5); // atteso 12
    if (a == 12)
        sig += 1;

    b = bar(9); // atteso 18
    if (b == 18)
        sig += 2;

    c = foo(1) + bar(2); // atteso 8 + 4 = 12
    if (c == 12)
        sig += 4;

    // firma finale
    m[2] = (u32)a; // 12
    m[3] = (u32)b; // 18
    m[4] = (u32)c; // 12
    m[5] = sig;    // 7
    m[6] = 333;    // deve sempre essere scritto
    m[7] = 444;    // deve sempre essere scritto

    while (1)
    {
    }

    return 0;
}
