//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

module trace;
 
private nothrow pure void SendCommand(in int command, in void* message)
{
    asm
    {
	"mov r0, %[cmd]; 
	mov r1, %[msg]; 
	bkpt #0xAB"
	:                              
	: [cmd] "r" command, [msg] "r" message
	: "r0", "r1";
    };
}

private static nothrow pure void SendMessage(in void* ptr, in uint length)
{
    // Create semihosting message message
    uint[3] message =
    [
	2, 	          // stderr
	cast(uint)ptr,    // ptr to string
	length            // size of string
    ];
    
    // Send semihosting command
    // 0x05 = Write
    SendCommand(0x05, &message);
}
 
struct Trace
{    
    static nothrow pure void Write(in string text)
    {
	SendMessage(text.ptr, text.length);
    }
    
    static nothrow pure void Write(uint value)
    {
	//Will use at most 10 digits, for a 32-bit base-10 number
	char[10] buffer; 
	
	//the end of the buffer.  Used to compute length of string
	char* end = buffer.ptr + buffer.length;
	
	//Print digit to the end of the buffer starting with the
	//least significant bit first.
	char* p = end;
	do
	{
	    *p-- = '0' + (value % 10);
	} while(value / 10);

	//p = pointer to most significant digit
	//end -p = length of string
	SendMessage(p, end - p);
    }
    
    static nothrow pure void Write(A...)(A a)
    {
	foreach(t; a)
	{
	    Write(t);
	}
    }
    
    static nothrow pure void WriteLine(A...)(A a)
    {
	foreach(t; a)
	{
	    Write(t);
	}
	Write("\r\n");
    }
}