// memory.d

module memory;
import trace;

extern(C) void* memset(void* dest, int value, size_t num)
{
    byte* d = cast(byte*)dest;
    for(int i = 0; i < num; i++)
    {
        d[i] = cast(byte)value;
    }
    
    return dest;
} 
