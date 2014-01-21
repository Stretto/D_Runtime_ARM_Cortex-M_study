//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

module start;

import trace;
import memory;
import reference;
import isr;
import mmio;
  
extern(C) __gshared void * _Dmodule_ref;

extern(C) void _d_assert_msg(string msg, string file, uint line)
{
    Trace.WriteLine(file, ":", line, ": ", msg);
}

extern(C) void _d_assert(string file, uint line)
{
    Trace.WriteLine(file, ":", line);
}

extern(C) void _Unwind_Resume(void *ucbp)
{
    Trace.WriteLine("_Unwind_Resume");
}

extern(C) extern __gshared uint __data_rom_begin;
extern(C) extern __gshared uint __data_ram_begin;
extern(C) extern __gshared uint __data_ram_end;
extern(C) extern __gshared uint __bss_begin;
extern(C) extern __gshared uint __bss_end;

struct TestStruct(uint value)
{        
    static uint GetVar()
    {
	return value;
    }
}

struct MyRegister
{
    mixin Register!(0x2000_0000, 0x0000_0000);

    static BitField!(size_t, 31,  0, Policy.Read)      EntireRegister;
    static BitField!(ushort, 16,  1, Policy.Read)      Bits16To1;
    static Bit!(0, Policy.Read)     Bit0;
    static BitField!(ubyte,  24, 17, Policy.ReadWrite) Bits24To17;
}


void DoFunction()
{     
    Trace.WriteLine(cast(uint)(MyRegister.Bit0.Value));
}

extern(C) private void OnHardFault()
{
    Trace.WriteLine("Hard Fault");
    while(true)
    { }
}

extern(C) private void OnReset()
{
    Trace.Write("Copying...");
    memcpy(&__data_ram_begin, &__data_rom_begin, cast(size_t)(&__data_ram_end) - cast(size_t)(&__data_ram_begin) + 1);
    memset(&__bss_begin, 0, cast(size_t)(&__bss_end) - cast(size_t)(&__bss_begin) + 1);
    Trace.WriteLine("Done");
    
    DoFunction();
    
    Trace.WriteLine("Done"); 
    while(true)
    { }
}