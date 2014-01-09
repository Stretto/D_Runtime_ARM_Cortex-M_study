/*********************************************************************************************
Memory Spaces Definitions
*********************************************************************************************/
MEMORY
{
  CCRAM    (rxw) : ORIGIN = 0x10000000, LENGTH =   64k
  SRAM     (rxw) : ORIGIN = 0x20000000, LENGTH =  128k
  FLASH    (rx)  : ORIGIN = 0x08000000, LENGTH = 1024k
}

_stackStart = ORIGIN(CCRAM) + LENGTH(CCRAM);

/*********************************************************************************************
 Section Definitions
*********************************************************************************************/
SECTIONS
{  

    /* Don't need exception stuff right now */
    /DISCARD/ :
    {
	*(.ARM.extab*)
	*(.ARM.exidx*)
    }
    
    .text :       
    {
	LONG(_stackStart);            /* Initial stack pointer */
	KEEP(*(*.ISRVectorTable))     /* Interrupt vector table */
	
	. = ALIGN(4);
	/* the code */
	*(SORT_BY_NAME(.text))      
	*(SORT_BY_NAME(.text*))  
	
	/* for "hello\r\n" string constant */
	. = ALIGN(4);
	*(SORT_BY_NAME(.rodata))
	*(SORT_BY_NAME(.rodata*))

	. = ALIGN(4);
	__data_rom_begin = .;
    } >FLASH

    .data : AT (__data_rom_begin)
    {
	. = ALIGN(4);
	__data_ram_begin = .;
	
	. = ALIGN(4);
	KEEP(*(SORT_BY_NAME(.data.*init*)))
	*(SORT_BY_NAME(.data))
	*(SORT_BY_NAME(.data*))

	. = ALIGN(4);
	__data_ram_end = .;
    } >SRAM
    
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