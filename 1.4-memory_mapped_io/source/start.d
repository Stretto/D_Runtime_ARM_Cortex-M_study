//start.d

import trace;
import mmio;
import test;
import gcc.attribute;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias ISR = void function(); // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset; // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault; // Pointer to hard fault handler, OnHardFault

// Handle any hard faults here
void OnHardFault()
{
    // Display a message notifying us that a hard fault occurred
    trace.writeLine("Hard Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

void OnReset()
{
    MyRegister.Bit0.value = true;
    
    if (MyRegister.Bit0.value)
    {
        MyRegister.Bit1.value = true;
    }
    
    //static assert(false, __traits(parent, MyRegister.Bit0).stringof);
    
    MyRegister.setValue!(
        MyRegister.Bit1, true,
        MyRegister.Bit0, true)();
        


    while(true)
    { 
        //Test.Bit0.value = !Test.Bit0.value;
        trace.writeLine(MyRegister.Bits1to0.value);
    }
}