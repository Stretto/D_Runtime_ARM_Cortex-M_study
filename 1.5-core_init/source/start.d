//start.d

import trace;
import mmio;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias void function() ISR; // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset; // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault; // Pointer to hard fault handler, OnHardFault

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

struct MyRegister
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(0x2000_1000, 0x0000_0000);
    
    alias EntireRegister = BitField!(31,  0, Policy.ReadWrite);
    alias Bits16To1 = BitField!(17,  2, Policy.ReadWrite);
    alias Bit0 = Bit!(0, Policy.ReadWrite);    
}

void OnReset()
{     
    MyRegister.EntireRegister.Value = 0b0101_0101_0101_0101_0101_0101_0101_0101;
    MyRegister.Bits16To1.Value = 0b1111_1111_1111_1111;
    MyRegister.Bit0.Value = false;
    
    assert(MyRegister.EntireRegister.Value == 0b0101_0101_0101_0111_1111_1111_1111_1100);
    
    trace.WriteLine("Success!");
    
    while(true)
    { }
}