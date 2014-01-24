module trace;

/************************************************************************************
* Initiate semihosting command
*/
private void PerformCommand(in int command, in void* message)
{
  // LDC and GDC use slightly different inline assembly syntax, so we have to 
  // differentiate them with D's conditional compilation feature, version.
  version(LDC)
  {
    __asm
    (
      "mov r0, $0;
      mov r1, $1;
      bkpt #0xAB",
      "r,r,~{r0},~{r1}",
      command, message
    );
  }
  else version(GNU)
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
}

/************************************************************************************
* Create semihosting message and forward it to PerformCommand
*/
private void SendMessage(in void* ptr, in uint length)
{
    // Create semihosting message message
    uint[3] message =
    [
        2,              // stderr
        cast(uint)ptr, // ptr to string
        length         // size of string
    ];
    
    // Send semihosting command
    // 0x05 = Write
    PerformCommand(0x05, &message);
}

/************************************************************************************
* Print unsigned integer
*/
void Write(uint value, uint base = 10)
{
    assert(base >= 2 && base <= 16);
    
    //Will use at most 10 digits, for a 32-bit base-10 number
    char[10] buffer;
    
    //the end of the buffer. Used to compute length of string
    char* end = buffer.ptr + buffer.length;
    
    //Print digit to the end of the buffer starting with the
    //least significant bit first.
    char* p = end;
    do
    {
	uint index = value % base;
	p--;
	*p = cast(char)(index <= 9 ? '0' + index : 'A' + (index - 10));
	value /= base;
    } while(value);

    //p = pointer to most significant digit
    //end - p = length of string
    SendMessage(p, end - p);
}

/************************************************************************************
* Print signed integer
*/
void Write(int value, uint base = 10)
{
    // if negative, write minus sign and get absolute value
    if (value < 0)
    {
	Write("-");
	Write(cast(uint)(value * -1), base);
    }
    // if greater than or equal to 0, just treat it as an unsigned int
    else
    {
	Write(cast(uint)value, base);
    }    
}

/************************************************************************************
* Print unsigned integer with a new line
*/
void WriteLine(uint value, uint base = 10)
{
    Write(value, base);
    Write("\r\n");
}

/************************************************************************************
* Print signed integer with a new line
*/
void WriteLine(int value, uint base = 10)
{
    Write(value, base);
    Write("\r\n");
}

/************************************************************************************
* Print string of charactes
*/
void Write(in string text)
{
    SendMessage(text.ptr, text.length);
}

/************************************************************************************
* Print several values at once
*/
void Write(A...)(in A a)
{
    foreach(t; a)
    {
	Write(t);
    }
}

/************************************************************************************
* Print several values at once with a new line
*/
void WriteLine(A...)(in A a)
{
    foreach(t; a)
    {
	Write(t);
    }
    Write("\r\n");
}
