module bus;

// see pp. 63 of the STM32F4 datasheet

final abstract class CorePeripherals
{
    static @property uint address()
    {
        return 0xE000_0000;
    }
}

final abstract class AHB1
{
    static @property uint address()
    {
        return 0x4002_0000;
    }
}

final abstract class AHB2
{
    static @property uint address()
    {
        return 0x5000_0000;
    }
}

final abstract class AHB3
{
    static @property uint address()
    {
        return 0x6000_0000;
    }
}

final abstract class APB1
{
    static @property uint address()
    {
        return 0x4000_0000;
    }
}

final abstract class APB2
{
    static @property uint address()
    {
        return 0x4001_0000;
    }
}