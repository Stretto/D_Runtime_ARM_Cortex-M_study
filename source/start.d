//start.d

import trace;
import mmio;
import gcc;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias void function() ISR; // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset; // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault; // Pointer to hard fault handler, OnHardFault
extern(C) immutable ISR MPUFaultHandler = &OnMPUFault;
extern(C) immutable ISR BusFaultHandler = &OnBusFault;
extern(C) immutable ISR UsageFaultHandler = &OnUsageFault;

extern(C) extern __gshared uint __bss_begin;
extern(C) extern __gshared uint __bss_end;

// Handle any hard faults here
void OnHardFault()
{
    // Display a message notifying us that a hard fault occurred
    trace.WriteLine("Hard Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

void OnMPUFault()
{
    // Display a message notifying us that a MPU fault occurred
    trace.WriteLine("MPU Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

void OnBusFault()
{
    // Display a message notifying us that a bus fault occurred
    trace.WriteLine("Bus Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

void OnUsageFault()
{
    // Display a message notifying us that a usage fault occurred
    trace.WriteLine("Usage Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

struct MyRegister
{
    mixin Register!(0x2000_1000, 0x0000_0000);
    
    alias BitField!(size_t, 31,  0, Policy.ReadWrite) EntireRegister;

    __gshared EntireRegister entireRegister;
    
//     static __gshared BitField!(size_t, 31,  0, Policy.ReadWrite) EntireRegister;
//     static __gshared BitField!(ushort, 16,  1, Policy.Read)      Bits16To1;
//     static __gshared Bit     !(             0, Policy.Read)      Bit0;
//     static __gshared BitField!(ubyte,  24, 17, Policy.ReadWrite) Bits24To17;
    
    
}

void OnReset()
{
//     Trace.Write("Copying...");
//     memcpy(&__data_ram_begin, &__data_rom_begin, cast(size_t)(&__data_ram_end) - cast(size_t)(&__data_ram_begin) + 1);
//     memset(&__bss_begin, 0, cast(size_t)(&__bss_end) - cast(size_t)(&__bss_begin) + 1);
//     Trace.WriteLine("Done");
    
    trace.WriteLine("Here");
    MyRegister.EntireRegister.Value = 0xAAu;
    trace.WriteLine(MyRegister.EntireRegister.Value);
    
    trace.WriteLine("Here2");
    MyRegister r;
    trace.WriteLine(r.EntireRegister.Value);
    
    while(true)
    { }
}