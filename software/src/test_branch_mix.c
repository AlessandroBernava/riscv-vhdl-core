typedef unsigned int u32;
typedef int s32;

int main(void)
{
    volatile u32 *m = (volatile u32 *)0x00001000;

    s32 a = -5;
    s32 b = 3;
    u32 ua = (u32)a;
    u32 ub = (u32)b;

    u32 score = 0;

    if (a < b)
        score += 1; // BLT signed: true
    if (a >= b)
        score += 2; // BGE signed: false

    if (ua < ub)
        score += 4; // BLTU unsigned: false, because 0xFFFFFFFB > 3
    if (ua >= ub)
        score += 8; // BGEU unsigned: true

    s32 x = 10;
    s32 y = 10;
    if (x == y)
        score += 16; // BEQ: true
    if (x != y)
        score += 32; // BNE: false

    m[0] = (u32)a; // 0xFFFFFFFB
    m[1] = (u32)b; // 3
    m[2] = score;  // expected 25

    s32 c = (s32)m[0];
    s32 d = (s32)m[1];
    s32 sum = c + d; // -5 + 3 = -2
    m[3] = (u32)sum; // 0xFFFFFFFE

    if (sum < 0)
        score += 64; // true
    m[4] = score;    // expected 89

    while (1)
    {
    }

    return 0;
}
