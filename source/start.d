// start.d

import trace;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias void function() ISR;                                // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset;          // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault;  // Pointer to entry point, OnReset

// Handle and hard faults here
void OnHardFault()
{
    // Display a message notifying us that a hard fault occurred
    trace.WriteLine("Hard Fault");
    
    // Enter an infinite loop so we can use the debugger
    // to examine registers, memory, etc...
    while(true)
    { }
}

// The program's entry point
void OnReset()
{    
    // run repeatedly
    while(true)
    {
	uint x = 123;
	string a = "abcd";
	a.WriteLine();
	x.WriteLine(16u);
	x.WriteLine(2u);
	x.WriteLine();
	trace.WriteLine("abcd ", 123, " x");
    }
}