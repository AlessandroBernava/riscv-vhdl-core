typedef unsigned int u32;
typedef signed int s32;

static s32 mix_step(s32 x, s32 y)
{
    s32 t0 = x + y;
    s32 t1 = x ^ y;
    s32 t2 = (t0 << 1) - t1;
    return t2;
}

void main(void)
{
    volatile u32 *m = (volatile u32 *)0x00001000;

    s32 a = 5;
    s32 b = 7;
    s32 c = -3;

    u32 ua = 0xFFFFFFFFu;
    u32 ub = 12u;

    s32 x[8];
    u32 y[8];

    for (u32 i = 0; i < 8; i++)
    {
        x[i] = 0;
        y[i] = 0;
    }

    /* 1. ALU / shifts */
    x[0] = a + b;               /* 12 */
    x[1] = b - a;               /* 2 */
    x[2] = (a << 2) + (b >> 1); /* 20 + 3 = 23 */
    x[3] = (a & b);             /* 5 */
    x[4] = (a | b);             /* 7 */
    x[5] = (a ^ b);             /* 2 */
    x[6] = (c >> 1);            /* -2 if arithmetic shift */
    x[7] = mix_step(a, b);      /* ((5+7)<<1) - (5^7) = 24 - 2 = 22 */

    /* 2. signed/unsigned compares */
    y[0] = (c < 0) ? 1u : 0u;       /* 1 */
    y[1] = (a < b) ? 1u : 0u;       /* 1 */
    y[2] = (ua < ub) ? 1u : 0u;     /* 0 */
    y[3] = (ua > ub) ? 1u : 0u;     /* 1 */
    y[4] = ((u32)c < ub) ? 1u : 0u; /* 0, because 0xFFFFFFFD > 12 */
    y[5] = ((s32)ua < 0) ? 1u : 0u; /* 1 */
    y[6] = (a == 5) ? 1u : 0u;      /* 1 */
    y[7] = (a != b) ? 1u : 0u;      /* 1 */
    // m[40] = 0; Debug

    /* 3. first loop */
    s32 sum1 = 0;
    for (s32 i = 0; i < 16; i++)
    {
        sum1 += i; /* 120 */
    }
    m[40] = (u32)sum1; /* 0x00000078 */

    /* 4. second loop with branch pattern */
    s32 sum2 = 0;
    for (s32 j = 0; j < 16; j++)
    {
        if ((j & 1) == 0)
        {
            sum2 += j;
        }
        else
        {
            sum2 -= j;
        }
    }
    m[41] = (u32)sum2; /* 0xFFFFFFF8 */

    /* 5. write arrays to memory */
    for (u32 i = 0; i < 8; i++)
    {
        m[i] = (u32)x[i];
    }

    for (u32 i = 0; i < 8; i++)
    {
        m[8 + i] = y[i];
    }

    /* 6. memory dependent accumulation */
    u32 acc = 0;
    for (u32 i = 0; i < 16; i++)
    {
        acc = acc + m[i] + (acc << 1);
    }
    m[42] = acc;

    // 7. reload check
    u32 chk = m[0] ^ m[1] ^ m[2] ^ m[3];
    chk ^= m[8] ^ m[9] ^ m[10] ^ m[11];
    m[43] = chk;

    // 8. signature
    m[44] = 0x13579BDFu;
}
