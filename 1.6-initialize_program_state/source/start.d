//start.d

import trace;
import memory;
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

@attribute("naked") void OnReset()
{
    // Enable Core-coupled memory for stack
    //MyPeripheral.MyRegister.Bits15to8.value = 3; 

    asm
    {
        " ldr r2, handler_address
          bx r2
          handler_address: .word main";
    };
}

          __gshared           char a;           // data segment, initialized by compiler
          __gshared           char b = 'B';     // data segment, initialized by user
          __gshared immutable char c;           // data segment, initialized by compiler
extern(C) __gshared immutable char d;           // data segment, initialized by compiler
extern(C) __gshared           char e;           // data segment, initialized by compiler

          __gshared           char f = void;    // bss segment, initialized to void

          __gshared immutable char g = 'G';     // rodata segment, initialized by user
extern(C) __gshared immutable char h = 'H';     // rodata segment, initialized by user

// compiler crash, test later
// __gshared immutable char i = void;           // rodata segment, initialized by user

// defined in the linker
extern(C) extern __gshared ubyte __text_end__;
extern(C) extern __gshared ubyte __data_start__;
extern(C) extern __gshared ubyte __data_end__;
extern(C) extern __gshared ubyte __bss_start__;
extern(C) extern __gshared ubyte __bss_end__;

extern(C) void main()
{    
    // copy data segment out of ROM and into RAM
    memcpy(&__data_start__, &__text_end__, &__data_end__ - &__data_start__);
    
    // zero out variables initialized to void
    memset(&__bss_start__, 0, &__bss_end__ - &__bss_start__);

    while(true)
    {
        trace.writeLine("x");
        
        trace.write(cast(uint)&a, 16u);
        trace.writeLine(": ", a);
        
        trace.write(cast(uint)&b, 16u);
        trace.writeLine(": ", b);
        
        trace.write(cast(uint)&c, 16u);
        trace.writeLine(": ", c);
        
        trace.write(cast(uint)&d, 16u);
        trace.writeLine(": ", d);
        
        trace.write(cast(uint)&e, 16u);
        trace.writeLine(": ", e);
        
        trace.write(cast(uint)&f, 16u);
        trace.writeLine(": ", f);
        
        trace.write(cast(uint)&g, 16u);
        trace.writeLine(": ", g);
        
        trace.write(cast(uint)&h, 16u);
        trace.writeLine(": ", h);
        
//         trace.write(cast(uint)&i, 16u);
//         trace.writeLine(": ", i);
    }
}