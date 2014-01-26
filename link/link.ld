MEMORY
{
  CCRAM (rxw) : ORIGIN = 0x10000000, LENGTH = 64k
  SRAM (rxw) : ORIGIN = 0x20000000, LENGTH = 128k
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1024k
}

_stackStart = ORIGIN(CCRAM) + LENGTH(CCRAM); /* Falling stack starts at the end of the CCM */

SECTIONS
{
    /* Not ready to implement exceptions yet, so discard this to prevent linker errors */
    /DISCARD/ :
    {
        *(.ARM.extab*)
        *(.ARM.exidx*)
    }

    /* Code */
    .text :
    {
        LONG(_stackStart);                 /* Initial stack pointer */
        KEEP(*(*.ResetHandler))            /* Pointer to program's entry point */
        LONG(0)                            /* Pointer to non-maskable interrupt handler (ignore for now) */
        KEEP(*(*.HardFaultHandler))        /* Pointer to hard fault handler */
        KEEP(*(*.MPUFaultHandler))         /* Pointer to hard fault handler */
        KEEP(*(*.BusFaultHandler))         /* Pointer to hard fault handler */
        KEEP(*(*.UsageFaultHandler))       /* Pointer to hard fault handler */
        *(*.text)                          /* Our executable code */
    } > FLASH

    /* Immutable data */
    .rodata :
    {
        *(*.rodata)
    } > FLASH
    
    .bss :
    {
        . = ALIGN(4);
        __bss_begin = .;
        
        *(SORT_BY_NAME(.bss))
        *(SORT_BY_NAME(.bss*))
        
        . = ALIGN(4);
        __bss_end = .;
    } >SRAM
}