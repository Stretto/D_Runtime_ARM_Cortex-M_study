// start.d

import trace;

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias extern(C) void function() ISR;              // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset;  // Pointer to entry point, OnReset

struct TestStruct
{
    uint TestVar;
    
    void Print()
    {
	trace.WriteLine("TestStruct.Print");
    }
}


// The program's entry point
extern(C) void OnReset()
{    
    TestStruct test;
    test.TestVar.Write();
    test.Print();
    
    //trace.Write("abcd", 124, "what");
    //trace.WriteLine("abc", 123);
	
    while(true)
    { }
}