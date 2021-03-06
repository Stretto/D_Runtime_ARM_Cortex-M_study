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
    //trace.writeLine("Hard Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

void OnReset()
{
//     MyPeripheral.MyRegister.Bits15to8.value = 3;   
//    MyPeripheral.MyRegister.Bits1to0.value = 3; 
    MyPeripheral.MyRegister.Bit0.value = true;
    
//     with(MyPeripheral.MyRegister)
//     {
//         setValue!(
//             Bit0, true,
//             Bit1, false)();
//     }

//     while(true)
//     { 
//         //Test.Bit0.value = !Test.Bit0.value;
//         trace.writeLine(MyPeripheral.MyRegister.Bits1to0.value);
//     }
}