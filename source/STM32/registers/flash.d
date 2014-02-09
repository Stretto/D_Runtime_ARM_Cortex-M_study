import mmio;
import ahb1 = STM32.registers.ahb1;

private immutable uint address = ahb1.address + 0x0000_3C00;

struct ACR
{ 
    // address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(address + 0x00);
    
    // Data cache reset
    // 0: Not reset
    // 1: Reset
    // This bit can be written only when the D cache is disabled.
    alias DCRST = Bit!(12, Policy.ReadWrite);

    // Instruction cache reset
    // 0: Not reset
    // 1: Reset
    // This bit can be written only when the I cache is disabled.
    alias ICRST = Bit!(11, Policy.ReadWrite);

    // Data cache enable
    // 0: Disabled
    // 1: Enabled
    alias DCEN = Bit!(10, Policy.ReadWrite);

    // Instruction cache enable
    // 0: Disabled
    // 1: Enabled
    alias ICEN = Bit!(9, Policy.ReadWrite);

    // Prefetch enable
    // 0: Disabled
    // 1: Enabled
    alias PRFTEN = Bit!(8, Policy.ReadWrite);

    // Latency
    // These bits represent the ratio of the CPU clock period to the Flash memory access time.
    // 000: Zero wait state
    // 001: One wait state
    // 010: Two wait states
    // 011: Three wait states
    // 100: Four wait states
    // 101: Five wait states
    // 110: Six wait states
    // 111: Seven wait states
    alias Latency = BitField!(2, 0, Policy.ReadWrite);
}
