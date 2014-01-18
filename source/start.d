// start.d

import trace;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias extern(C) void function() ISR;              // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset;  // Pointer to entry point, OnReset

// The program's entry point
extern(C) void OnReset()
{    
    // run repeatedly
    while(true)
    {
	uint x = 123;
	string a = "abcd";
	a.Write();
	x.Write(16u);
	x.Write();
	trace.WriteLine("abcd", 123, "x");
    }
}