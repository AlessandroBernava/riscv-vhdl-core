#include <stdint.h>

#define OUT ((volatile uint32_t *)0x00001200u)
// volatile unsigned int *OUT = (volatile unsigned int *)0x00001104u;
uint32_t a[4] = {1, 2, 3, 4};
uint32_t sum = 0;

int main(void)
{
    uint32_t i;
    uint32_t acc = 0;

    for (i = 0; i < 4; i++)
    {
        acc = acc + a[i];
    }

    sum = acc; // sum = 10

    OUT[0] = a[0]; // 1
    OUT[1] = a[1]; // 2
    OUT[2] = a[2]; // 3
    OUT[3] = a[3]; // 4
    OUT[4] = sum;  // 10

    if (sum == 10)
    {
        OUT[5] = 111;
    }
    else
    {
        OUT[5] = 222;
    }

    while (1)
    {
    }

    return 0;
}
