//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

module start;

import trace;
import memory;
import reference;
import isr;
  
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
 
__gshared int GlobalDataVar = 2;
__gshared int GlobalBssVar;


extern (C) Object _d_newclass(const ClassInfo ci)
{
    void* p;

    p = HeapMemory.Instance.Allocate(ci.init.length);
    
    return cast(Object) p;
}

extern(C) extern __gshared uint __data_rom_begin;
extern(C) extern __gshared uint __data_ram_begin;
extern(C) extern __gshared uint __data_ram_end;
extern(C) extern __gshared uint __bss_begin;
extern(C) extern __gshared uint __bss_end;

class MyClass
{
    uint x;
    
    this()
    {
	Trace.WriteLine("Constructor");
    }
    
    ~this()
    {
	Trace.WriteLine("Destructor");
    }
}

void DoFunction()
{     
    auto r1 = Reference!MyClass.Create();
    auto r2 = Reference!MyClass.Create();
    
    r1.x = 11;
    r2.x = 22;
    
    Trace.WriteLine("r1: ", r1.Count, ": ", r1.x);
    Trace.WriteLine("r2: ", r2.Count, ": ", r2.x);
    
    r1 = r2;	
    
    Trace.WriteLine("r1: ", r1.Count, ": ", r1.x);
    Trace.WriteLine("r2: ", r2.Count, ": ", r2.x);
    
    MyClass c = new MyClass();
    c.x = 10;
    
    c.destroy();
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