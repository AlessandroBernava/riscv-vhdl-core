#define LED_ADDR 0x00001000u
#define LED_REG  (*(volatile unsigned int *)LED_ADDR)

int main(void)
{
    LED_REG = 1u;

    while (1) {
    }
}
