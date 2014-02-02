
import mmio;

private immutable uint Address = 0x0 + 0x00003C00;

struct ACR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x00);
    
    // Data cache reset
    // 0: Not reset
    // 1: Reset
    // This bit can be written only when the D cache is disabled.
    alias Bit!(12, Policy.ReadWrite) DCRST;

    // Instruction cache reset
    // 0: Not reset
    // 1: Reset
    // This bit can be written only when the I cache is disabled.
    alias Bit!(11, Policy.ReadWrite) ICRST;

    // Data cache enable
    // 0: Disabled
    // 1: Enabled
    alias Bit!(10, Policy.ReadWrite) DCEN;

    // Instruction cache enable
    // 0: Disabled
    // 1: Enabled
    alias Bit!(9, Policy.ReadWrite) ICEN;

    // Prefetch enable
    // 0: Disabled
    // 1: Enabled
    alias Bit!(8, Policy.ReadWrite) PRFTEN;

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
    alias BitField!(uint, 2, 0, Policy.ReadWrite) Latency;
}
