#include <stdint.h>

#define MMIO_BASE 0x1000u
#define DATA_BASE 0x1100u
#define LED_ADDR 0x10FCu
#define PASS 0x0000CAFEu
#define FAIL 0x0000DEADu
#define REG32(a) (*(volatile uint32_t *)(uintptr_t)(a))

static volatile uint32_t ram[32] __attribute__((section(".test_ram"), used));
static volatile uint32_t checks;
static volatile uint32_t phase;

static void bad(uint32_t id, uint32_t got, uint32_t exp)
{
    REG32(0x1000) = 0x52563332u;
    REG32(0x1004) = FAIL;
    REG32(0x1008) = phase;
    REG32(0x100C) = id;
    REG32(0x1010) = got;
    REG32(0x1014) = exp;
    REG32(0x1018) = checks;
    REG32(LED_ADDR) = FAIL;
    for (;;)
        __asm__ volatile("nop");
}
static void ck(uint32_t id, uint32_t got, uint32_t exp)
{
    ++checks;
    if (got != exp)
        bad(id, got, exp);
}

static uint32_t alu_tests(void)
{
    uint32_t a = 0x12345678u, b = 0x0F0F0F0Fu, r;
    phase = 1;
    __asm__ volatile("add %0,%1,%2" : "=r"(r) : "r"(a), "r"(b));
    ck(0x101, r, 0x21436587u);
    __asm__ volatile("sub %0,%1,%2" : "=r"(r) : "r"(a), "r"(b));
  ck(0x102,r,0x03254769u);
    __asm__ volatile("and %0,%1,%2" : "=r"(r) : "r"(a), "r"(b));
    ck(0x103, r, 0x02040608u);
    __asm__ volatile("or %0,%1,%2" : "=r"(r) : "r"(a), "r"(b));
    ck(0x104, r, 0x1F3F5F7Fu);
    __asm__ volatile("xor %0,%1,%2" : "=r"(r) : "r"(a), "r"(b));
    ck(0x105, r, 0x1D3B5977u);
    __asm__ volatile("sll %0,%1,%2" : "=r"(r) : "r"(1u), "r"(8u));
    ck(0x106, r, 0x100u);
    __asm__ volatile("srl %0,%1,%2" : "=r"(r) : "r"(0x80000000u), "r"(4u));
    ck(0x107, r, 0x08000000u);
    __asm__ volatile("sra %0,%1,%2" : "=r"(r) : "r"(0x80000000u), "r"(4u));
    ck(0x108, r, 0xF8000000u);
    __asm__ volatile("slt %0,%1,%2" : "=r"(r) : "r"(0x80000000u), "r"(1u));
    ck(0x109, r, 1u);
    __asm__ volatile("sltu %0,%1,%2" : "=r"(r) : "r"(1u), "r"(0x80000000u));
    ck(0x10A, r, 1u);
    __asm__ volatile("addi %0,%1,-1" : "=r"(r) : "r"(1u));
    ck(0x10B, r, 0);
    __asm__ volatile("andi %0,%1,15" : "=r"(r) : "r"(0x1234u));
    ck(0x10C, r, 4u);
    __asm__ volatile("ori %0,%1,15" : "=r"(r) : "r"(0x1200u));
    ck(0x10D, r, 0x120Fu);
    __asm__ volatile("xori %0,%1,-1" : "=r"(r) : "r"(0x12345678u));
    ck(0x10E, r, 0xEDCBA987u);
    __asm__ volatile("slli %0,%1,31" : "=r"(r) : "r"(1u));
    ck(0x10F, r, 0x80000000u);
    __asm__ volatile("srli %0,%1,31" : "=r"(r) : "r"(0x80000000u));
    ck(0x110, r, 1u);
    __asm__ volatile("srai %0,%1,31" : "=r"(r) : "r"(0x80000000u));
    ck(0x111, r, 0xFFFFFFFFu);
    __asm__ volatile("lui %0,0xABCDE" : "=r"(r));
    ck(0x112, r, 0xABCDE000u);
    return r;
}

static void branch_tests(void)
{
    uint32_t r;
    phase = 2;
#define B(id, ins, a, b, want)                                                             \
    do                                                                                     \
    {                                                                                      \
        uint32_t x = (a), y = (b);                                                         \
        __asm__ volatile(                                                                  \
            "addi %0,zero,0\n\t" ins " %1,%2,1f\n\tjal zero,2f\n\t1: addi %0,zero,1\n\t2:" \
            : "=&r"(r) : "r"(x), "r"(y));                                                  \
        ck(id, r, want);                                                                   \
    } while (0)
    B(0x201, "beq", 3, 3, 1);
    B(0x202, "bne", 3, 4, 1);
    B(0x203, "blt", 0x80000000u, 1, 1);
    B(0x204, "bge", 5, 0xFFFFFFFFu, 1);
    B(0x205, "bltu", 1, 0xFFFFFFFFu, 1);
    B(0x206, "bgeu", 0xFFFFFFFFu, 1, 1);
#undef B
    __asm__ volatile("addi %0,zero,0\n\tjal %1,1f\n\taddi %0,zero,99\n\t1:"
                     : "=&r"(r), "=&r"(r));
    /* The previous inline check is deliberately not used for link value. */
    uint32_t n = 0;
    for (uint32_t i = 0; i < 8; i++)
        n++;
    ck(0x207, n, 8);
}

static uint32_t load8(uintptr_t p)
{
    uint32_t x;
    __asm__ volatile("lbu %0,0(%1)" : "=r"(x) : "r"(p) : "memory");
    return x;
}
static uint32_t load8s(uintptr_t p)
{
    uint32_t x;
    __asm__ volatile("lb %0,0(%1)" : "=r"(x) : "r"(p) : "memory");
    return x;
}
static uint32_t load16(uintptr_t p)
{
    uint32_t x;
    __asm__ volatile("lhu %0,0(%1)" : "=r"(x) : "r"(p) : "memory");
    return x;
}
static uint32_t load32(uintptr_t p)
{
    uint32_t x;
    __asm__ volatile("lw %0,0(%1)" : "=r"(x) : "r"(p) : "memory");
    return x;
}
static void store8(uintptr_t p, uint32_t x) { __asm__ volatile("sb %0,0(%1)" ::"r"(x), "r"(p) : "memory"); }
static void store16(uintptr_t p, uint32_t x) { __asm__ volatile("sh %0,0(%1)" ::"r"(x), "r"(p) : "memory"); }

static void memory_tests(void)
{
    phase = 3;
    uintptr_t p = (uintptr_t)ram;
    ram[0] = 0x80FF7F01u;
    ram[1] = 0xA5A5A5A5u;
    ck(0x301, load32(p), 0x80FF7F01u);
    ck(0x302, load8(p), 1u);
    ck(0x303, load8s(p + 1), 0x7Fu);
    ck(0x304, load16(p), 0x7F01u);
    ck(0x305, load16(p + 2), 0x80FFu);
    ck(0x306, load32(p + 4), 0xA5A5A5A5u);
    store8(p + 1, 0x22);
    ck(0x307, load32(p), 0x80FF2201u);
    store16(p + 2, 0x3344);
    ck(0x308, load32(p), 0x33442201u);
    for (uint32_t i = 2; i < 16; i++)
    {
        ram[i] = 0xA0000000u | i;
        ck(0x320 + i, ram[i], 0xA0000000u | i);
    }
}

static void mmio_tests(void)
{
    phase = 4;
    for (uint32_t i = 0; i < 8; i++)
        REG32(MMIO_BASE + 4 * i) = 0x55000000u | i;
    for (uint32_t i = 0; i < 8; i++)
        ck(0x401 + i, REG32(MMIO_BASE + 4 * i), 0x55000000u | i);
    REG32(MMIO_BASE + 0x20) = 0x11223344u;
    ck(0x410, REG32(MMIO_BASE + 0x20), 0x11223344u);
    store8(MMIO_BASE + 0x21, 0xAA);
    ck(0x411, REG32(MMIO_BASE + 0x20), 0x1122AA44u);
    REG32(LED_ADDR) = 0x2468ACE0u;
    ck(0x412, REG32(LED_ADDR), 0x2468ACE0u);
    ram[16] = 0x13579BDFu;
    ck(0x413, ram[16], 0x13579BDFu);
    ck(0x414, REG32(MMIO_BASE + 0x20), 0x1122AA44u);
}

static void hazard_tests(void)
{
    phase = 5;
    uintptr_t p = (uintptr_t)&ram[20];
    uint32_t r;
    __asm__ volatile("addi t0,zero,7\n\taddi t1,t0,5\n\tadd t2,t1,t0\n\tsw t2,0(%1)\n\tlw t3,0(%1)\n\taddi %0,t3,1"
                     : "=&r"(r) : "r"(p) : "t0", "t1", "t2", "t3", "memory");
    ck(0x501, r, 20);
    __asm__ volatile("lw t0,0(%1)\n\taddi %0,t0,1" : "=&r"(r) : "r"(p) : "t0", "memory");
    ck(0x502, r, 20);
}

int main(void)
{
    /* The expected first data word is deliberately at DMEM base. */
    phase = 0;
    ck(1, (uint32_t)(uintptr_t)ram, DATA_BASE);
    ram[0] = 0x52563332u;
    REG32(MMIO_BASE) = ram[0];
    ck(2, REG32(MMIO_BASE), 0x52563332u);
    alu_tests();
    branch_tests();
    memory_tests();
    mmio_tests();
    hazard_tests();
    phase = 6;
    REG32(MMIO_BASE) = 0x52563332u;
    REG32(MMIO_BASE + 4) = PASS;
    REG32(LED_ADDR) = PASS;
    ram[0] = PASS;
    ram[1] = checks;
    for (;;)
        __asm__ volatile("nop");
}
