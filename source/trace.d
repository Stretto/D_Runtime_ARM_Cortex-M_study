//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

module trace;
 
private nothrow pure void SendCommand(int command, void* message)
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
 
struct Trace
{    
    static nothrow pure void Write(in string text)
    {
	// Create semihosting message message
	uint[3] message =
	[
	    2, 			      //stderr
	    cast(uint)text.ptr,    //ptr to string
	    text.length                             //size of string
	];
	
	//Send semihosting command
	SendCommand(0x05, &message);
    }
    
    static nothrow pure void Write(uint value)
    {
	char[32] buffer;
	
	char* p = buffer.ptr + 31;
	do
	{
	    p--;
	    *p = '0' + (value % 10);
	    value /= 10;
	} while(value > 0);

	uint[3] message =
	[
	    2, 			      //stderr
	    cast(uint)p,    //ptr to string
	    (buffer.ptr + 31) - p
	];
	
	//Send semihosting command
	SendCommand(0x05, &message);
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