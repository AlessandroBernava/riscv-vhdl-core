typedef unsigned int u32;
typedef int s32;
typedef signed char s8;
typedef short s16;

int main(void)
{
    volatile u32 *m32 = (volatile u32 *)0x00001000;
    volatile s8 *m8 = (volatile s8 *)0x00001000;
    volatile s16 *m16 = (volatile s16 *)0x00001000;

    u32 sig = 0;
    s32 a, b, c, d, e;

    // Pulizia firma finale
    m32[0] = 0;
    m32[1] = 0;
    m32[2] = 0;
    m32[3] = 0;
    m32[4] = 0;
    m32[5] = 0;

    // Preparo dati in memoria
    m8[0] = (s8)-128;   // 0x80
    m8[1] = (s8)127;    // 0x7F
    m16[1] = (s16)-256; // offset 2, cioè bytes [2..3] = 0xFF00

    // 1) LB seguito da branch signed
    a = m8[0]; // atteso: 0xFFFFFF80
    if (a < 0)
        sig += 1; // vero

    // 2) Altro LB signed, ma positivo
    b = m8[1]; // atteso: 0x0000007F
    if (b < 0)
        sig += 2; // falso
    if (b >= 0)
        sig += 4; // vero

    // 3) LH seguito da branch signed
    c = m16[1]; // atteso: 0xFFFFFF00
    if (c < 0)
        sig += 8; // vero
    if (c >= 0)
        sig += 16; // falso

    // 4) Load e confronto signed con altro registro
    d = m8[0]; // -128
    e = 5;
    if (d < e)
        sig += 32; // vero
    if (e < d)
        sig += 64; // falso

    // Firma finale tutta da m[0] in poi
    m32[0] = (u32)a; // 0xFFFFFF80
    m32[1] = (u32)b; // 0x0000007F
    m32[2] = (u32)c; // 0xFFFFFF00
    m32[3] = (u32)d; // 0xFFFFFF80
    m32[4] = (u32)e; // 0x00000005
    m32[5] = sig;    // 45

    while (1)
    {
    }

    return 0;
}
