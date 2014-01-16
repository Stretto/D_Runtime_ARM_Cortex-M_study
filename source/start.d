// start.d

// These are marked extern(C) to avoid name mangling, so we can refer to them in our linker script
alias extern(C) void function() ISR;              // Alias Interrupt Service Routine function pointers
extern(C) immutable ISR ResetHandler = &OnReset;  // Pointer to entry point, OnReset

void SendCommand(int command, void* message)
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

// The program's entry point
extern(C) void OnReset()
{
  // run repeatedly
  while(true)
  {
    // Create semihosting message
    uint[3] message =
      [
	2, 			            // stderr
	cast(uint)"Hello, World!\r\n".ptr,  // ptr to string
	15                                  // number of bytes in string
      ];
 
    // Send semihosting command
    SendCommand(0x05, &message);
  }
}