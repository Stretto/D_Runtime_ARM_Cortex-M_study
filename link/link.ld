/* link.ld */

MEMORY
{
  CCRAM    (rxw) : ORIGIN = 0x10000000, LENGTH =   64k
  SRAM     (rxw) : ORIGIN = 0x20000000, LENGTH =  128k
  FLASH    (rx)  : ORIGIN = 0x08000000, LENGTH = 1024k
}

_stackStart = ORIGIN(CCRAM) + LENGTH(CCRAM);  /* Falling stack starts at the end of the CCM */

SECTIONS
{  
  .text :       
  {
    LONG(_stackStart);                        /* Initial stack pointer */
    KEEP(*(*.rodata.ResetHandler))            /* Pointer to program's entry point   */
    *(*.text)                                 /* Our executable code */
  } > FLASH
  
  .rodata :
  {
    *(*.rodata)                               /* The "Hello, World!\r\n" immutable string */
  } > FLASH
}