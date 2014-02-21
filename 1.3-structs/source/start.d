// start.d

import trace;

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

struct TestStruct
{
    uint _testVar = 12;
    
    void Print()
    {
	trace.WriteLine("In TestStruct.Print");
    }
    
    @property uint TestVar()
    {
	return _testVar;
    }
    
    @property void TestVar(uint value)
    {
	_testVar = value;
    }
}


// The program's entry point
void OnReset()
{    
    TestStruct test;
        
    trace.WriteLine("TestStruct.TestVar is ", test.TestVar);
    test.TestVar = 13;
    trace.WriteLine("TestStruct.TestVar is ", test.TestVar);
    test.Print();
    	
    while(true)
    { }
}