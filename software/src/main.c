// prova per verificare funzionamento della data memory
/*
volatile int  *out = (volatile int *)0x00001000;

int main(void) {
    int a = 5;
    int b = 7;
    int c = a + b;
    *out = c;

    while (1) { }
    return 0;
}
*/

typedef unsigned int u32;
typedef signed int s32;

volatile u32 *const out = (volatile u32 *)0x00001000;

static u32 checksum(const volatile u32 *buf, u32 n)
{
    u32 h = 0x12345678u;
    for (u32 i = 0; i < n; i++)
    {
        h ^= buf[i] + 0x9e3779b9u + (h << 6) + (h >> 2);
    }
    return h;
}

// volatile u32 *const out = (volatile u32 *)0x00001000;
// volatile u32 *const guard = (volatile u32 *)0x000010FC; // ultimo word della zona out

int main(void)
{
    volatile u32 *m = out;
    // Inizializza guardia
    // *guard = 0xCAFED00Du;

    s32 a = 5;
    s32 b = 7;
    s32 c = -3;
    u32 ua = 0xFFFFFFFFu;
    u32 ub = 3u;

    s32 x[8];
    u32 y[8];

    // 1. ALU base
    x[0] = a + b; // 12
    x[1] = b - a; // 2
    x[2] = a + a + a + b;
    x[3] = (a << 2) + (b >> 1); // 20 + 3 = 23
    x[4] = (a & b);             // 5
    x[5] = (a | b);             // 7
    x[6] = (a ^ b);             // 2
    x[7] = (c >> 1);            // -2 se lo shift signed è corretto nel compilato/CPU

    // 2. Confronti signed / unsigned
    y[0] = (c < 0) ? 1u : 0u;       // 1
    y[1] = (a < b) ? 1u : 0u;       // 1
    y[2] = (ua < ub) ? 1u : 0u;     // 0 unsigned
    y[3] = (ua > ub) ? 1u : 0u;     // 1 unsigned
    y[4] = ((u32)c < ub) ? 1u : 0u; // unsigned compare
    y[5] = ((s32)ua < 0) ? 1u : 0u; // 1
    y[6] = (a == 5) ? 1u : 0u;      // 1
    y[7] = (a != b) ? 1u : 0u;      // 1

    // 3. Loop e branch

    s32 sum1 = 0;
    for (s32 i = 0; i < 16; i++)
    {
        sum1 += i; // 120
    }
    m[47] = (u32)sum1; // 120
    s32 sum2 = 0;
    for (s32 j = 0; j < 16; j++)
    {
        if ((j & 1) == 0)
        {
            sum2 += j; // 0+2+...+14 = 56
        }
        else
        {
            sum2 -= j; // -(1+3+...+15) = -64 => totale -8
        }
    }
    m[48] = (u32)sum2; // 0xFFFFFFF8

    // 4. Accessi in memoria e dipendenze
    for (u32 i = 0; i < 8; i++)
    {
        m[i] = (u32)x[i];
    }

    for (u32 i = 0; i < 8; i++)
    {
        m[8 + i] = y[i];
    }

    m[16] = (u32)sum1;

    m[17] = (u32)sum2;

    // 5. Load-use style via C
    u32 acc = 0;
    for (u32 i = 0; i < 18; i++)
    {
        acc = acc + m[i] + (acc << 1);
    }
    m[18] = acc;
    /*
          // 6. Piccolo test array/read-modify-write
          for (u32 i = 0; i < 8; i++)
          {
              m[24 + i] = (u32)((i << 1) + i + 3u);
          }

          for (u32 i = 0; i < 8; i++)
          {
              u32 t = m[24 + i];
              if (t & 1u)
              {
                  m[24 + i] = t ^ 0x55u;
              }
              else
              {
                  m[24 + i] = t + 0x10u;
              }
          }

      // 7. Firma finale
      u32 sig = checksum(m, 32);
      m[40] = sig;
      */
    // 8. Esiti attesi "grezzi" utili da controllare subito
    // m[41] = (u32)x[0];   // 12
    // m[42] = (u32)x[1];   // 2
    // m[43] = (u32)x[7];   // 0xFFFFFFFE
    // m[44] = y[0];        // 1
    // m[45] = y[2];        // 0
    // m[46] = y[3];        // 1

    m[49] = 0xCAFEBABEu; // PASS marker

    /*
    if (*guard != 0xCAFED00Du)
    {
        // Corruzione: qualcuno ha scritto oltre m[0..n]
        m[0] = 0xBADF00Du; // marker di errore
    }
*/
    while (1)
    {
    }
    return 0;
}
