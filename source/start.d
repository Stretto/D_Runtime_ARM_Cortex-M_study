// start.d

import trace;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias void function() ISR;                                // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset;          // Pointer to entry point, OnReset
extern(C) immutable ISR HardFaultHandler = &OnHardFault;  // Pointer to hard fault handler, OnHardFault

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
	uint intTest = 123;
	trace.Write("intTest (decimal):     "); intTest.WriteLine();
	trace.Write("intTest (hexadecimal): "); intTest.WriteLine(16u);
	trace.Write("intTest (binary):      "); intTest.WriteLine(2u);
	
	string stringTest = "abcd";
	stringTest.WriteLine();
	
	trace.WriteLine(stringTest, " ", intTest);
    }
}