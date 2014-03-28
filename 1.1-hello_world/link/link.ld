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
    /* Not ready to implement exceptions yet, so discard this to prevent linker errors */
    /DISCARD/ :
    {
        *(.ARM.extab*)
        *(.ARM.exidx*)
    }

    .text :       
    {
	LONG(_stackStart);                        /* Initial stack pointer */
	KEEP(*(*.ResetHandler))                   /* Pointer to program's entry point   */zz
	*(*.text)                                 /* Our executable code */
    } > FLASH

    .rodata :
    {
	*(*.rodata)                               /* The "Hello, World!\r\n" immutable string */
    } > FLASH
}