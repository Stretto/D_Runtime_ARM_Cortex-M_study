/****************************************************************************************
 Embedded Flash memory interface
*/
final abstract class Flash : Peripheral!(0x00003C00)
{
    /************************************************************************************
     Flash access control register
     The Flash access control register is used to enable/disable the acceleration features and
     control the Flash memory access time according to CPU frequency.
    */
    final abstract class ACR : Register!(0x00, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         Data cache reset 
         0: Data cache is not reset
         1: Data cache is reset
         This bit can be written only when the D cache is disabled.
        */
        alias DCRST = Bit!(12, Mutability.rw);

        /********************************************************************************
         Instruction cache reset 
         0: Instruction cache is not reset
         1: Instruction cache is reset
         This bit can be written only when the I cache is disabled.
        */
        alias ICRST = Bit!(11, Mutability.w);

        /********************************************************************************
         Data cache enable 
         0: Data cache is disabled
         1: Data cache is enabled
        */
        alias DCEN = Bit!(10, Mutability.rw);

        /********************************************************************************
         Instruction cache enable 
         0: Instruction cache is disabled
         1: Instruction cache is enabled
        */
        alias ICEN = Bit!(9, Mutability.rw);

        /********************************************************************************
         Prefetch enable 
         0: Prefetch is disabled
         1: Prefetch is enabled
        */
        alias PRFTEN = Bit!(8, Mutability.rw);

        /********************************************************************************
         Latency 
         These bits represent the ratio of the CPU clock period to the Flash memory access time.
         000: Zero wait state
         001: One wait state
         010: Two wait states
         011: Three wait states
         100: Four wait states
         101: Five wait states
         110: Six wait states
         111: Seven wait states
        */
        alias LATENCY = BitField!(2, 0, Mutability.rw);

    }
    /************************************************************************************
     Flash key register
     The Flash key register is used to allow access to the Flash control register and so, to allow
     program and erase operations.
    */
    final abstract class KEYR : Register!(0x04, Access.Word)
    {
        /********************************************************************************
         FPEC key 
         The following values must be programmed consecutively to unlock the FLASH_CR register
         and allow programming/erasing it:
         a) KEY1 = 0x45670123
         b) KEY2 = 0xCDEF89AB
        */
        alias FKEYR = BitField!(31, 0, Mutability.w);

    }
    /************************************************************************************
     Flash option key register
     The Flash option key register is used to allow program and erase operations in the user
     configuration sector.
    */
    final abstract class OPTKEYR : Register!(0x08, Access.Word)
    {
        /********************************************************************************
         Option byte key 
         The following values must be programmed consecutively to unlock the FLASH_OPTCR
         register and allow programming it:
         a) OPTKEY1 = 0x08192A3B
         b) OPTKEY2 = 0x4C5D6E7F
        */
        alias OPTKEYR = BitField!(31, 0, Mutability.w);

    }
    /************************************************************************************
     Flash status register
     The Flash status register gives information on ongoing program and erase operations.
    */
    final abstract class SR : Register!(0x0C, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         Busy 
         This bit indicates that a Flash memory operation is in progress. It is set at the beginning of a
         Flash memory operation and cleared when the operation finishes or an error occurs.
         0: no Flash memory operation ongoing
         1: Flash memory operation ongoing
        */
        alias BSY = Bit!(16, Mutability.r);

        /********************************************************************************
         Programming sequence error 
         Set by hardware when a write access to the Flash memory is performed by the code while
         the control register has not been correctly configured.
         Cleared by writing 1.
        */
        alias PGSERR = Bit!(7, Mutability.rc_w1);

        /********************************************************************************
         Programming parallelism error 
         Set by hardware when the size of the access (byte, half-word, word, double word) during the
         program sequence does not correspond to the parallelism configuration PSIZE (x8, x16,
         x32, x64).
         Cleared by writing 1.
        */
        alias PGPERR = Bit!(6, Mutability.rc_w1);

        /********************************************************************************
         Programming alignment error 
         Set by hardware when the data to program cannot be contained in the same 128-bit Flash
         memory row.
         Cleared by writing 1.
        */
        alias PGAERR = Bit!(5, Mutability.rc_w1);

        /********************************************************************************
         Write protection error 
         Set by hardware when an address to be erased/programmed belongs to a write-protected
         part of the Flash memory.
         Cleared by writing 1.
        */
        alias WRPERR = Bit!(4, Mutability.rc_w1);

        /********************************************************************************
         Operation error 
         Set by hardware when a flash operation (programming / erase /read) request is detected and
         can not be run because of parallelism, alignment, or write protection error. This bit is set only
         if error interrupts are enabled (ERRIE = 1).
        */
        alias OPERR = Bit!(1, Mutability.rc_w1);

        /********************************************************************************
         End of operation 
         Set by hardware when one or more Flash memory operations (program/erase) has/have
         completed successfully. It is set only if the end of operation interrupts are enabled (EOPIE =
         1).
         Cleared by writing a 1.
        */
        alias EOP = Bit!(0, Mutability.rc_w1);

    }
    /************************************************************************************
     Flash control register
     The Flash control register is used to configure and start Flash memory operations.
    */
    final abstract class CR : Register!(0x10, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         Lock 
         Write to 1 only. When it is set, this bit indicates that the FLASH_CR register is locked. It is
         cleared by hardware after detecting the unlock sequence.
         In the event of an unsuccessful unlock operation, this bit remains set until the next reset.
        */
        alias LOCK = Bit!(31, Mutability.rs);

        /********************************************************************************
         Error interrupt enable 
         This bit enables the interrupt generation when the OPERR bit in the FLASH_SR register is
         set to 1.
         0: Error interrupt generation disabled
         1: Error interrupt generation enabled
        */
        alias ERRIE = Bit!(25, Mutability.rw);

        /********************************************************************************
         End of operation interrupt enable 
         This bit enables the interrupt generation when the EOP bit in the FLASH_SR register goes
         to 1.
         0: Interrupt generation disabled
         1: Interrupt generation enabled
        */
        alias EOPIE = Bit!(24, Mutability.rw);

        /********************************************************************************
         Start 
         This bit triggers an erase operation when set. It is set only by software and cleared when the
         BSY bit is cleared.
        */
        alias STRT = Bit!(16, Mutability.rs);

        /********************************************************************************
         Program size 
         These bits select the program parallelism.
         00 program x8
         01 program x16
         10 program x32
         11 program x64
        */
        alias PSIZE = BitField!(9, 8, Mutability.rw);

        /********************************************************************************
         Sector number 
         These bits select the sector to erase.
         0000 sector 0
         0001 sector 1
         ...
         1011 sector 11
         Others not allowed
        */
        alias SNB = BitField!(6, 3, Mutability.rw);

        /********************************************************************************
         Mass Erase 
         Erase activated for all user sectors.
        */
        alias MER = Bit!(2, Mutability.rw);

        /********************************************************************************
         Sector Erase 
         Sector Erase activated.
        */
        alias SER = Bit!(1, Mutability.rw);

        /********************************************************************************
         Programming 
         Flash programming activated.
        */
        alias PG = Bit!(0, Mutability.rw);

    }
    /************************************************************************************
     Flash option control register
     The FLASH_OPTCR register is used to modify the user option bytes.  The option bits are loaded with values from Flash memory at
     reset release.
    */
    final abstract class OPTCR : Register!(0x14, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         nWRP[7:6] Not write protect 
         These bits contain the value of the write-protection option bytes after reset. They can be
         written to program a new write protect value into Flash memory.
         0: Write protection active on selected sector
         1: Write protection inactive on selected sector
        */
        alias nWRP = BitField!(27, 16, Mutability.rw);

        /********************************************************************************
         Read protect 
         These bits contain the value of the read-protection option level after reset. They can be
         written to program a new read protection value into Flash memory.
         0xAA: Level 0, read protection not active
         0xCC: Level 2, chip read protection active
         Others: Level 1, read protection of memories active
        */
        alias RDP = BitField!(15, 8, Mutability.rw);

        /********************************************************************************
         User option bytes 
         These bits contain the value of the user option byte after reset. They can be written to
         program a new user option byte value into Flash memory.
         Bit 7 nRST_STDBY
         Bit 6 nRST_STOP
         Bit 5 WDG_SW
         Note: When changing the WDG mode from hardware to software or from software to
         hardware, a system reset is required to make the change effective.
        */
        alias USER = BitField!(7, 5, Mutability.rw);

        /********************************************************************************
         BOR reset Level 
         These bits contain the supply level threshold that activates/releases the reset. They can be
         written to program a new BOR level. By default, BOR is off. When the supply voltage (VDD)
         drops below the selected BOR level, a device reset is generated.
         00: BOR Level 3 (VBOR3), brownout threshold level 3
         01: BOR Level 2 (VBOR2), brownout threshold level 2
         10: BOR Level 1 (VBOR1), brownout threshold level 1
         11: BOR off, POR/PDR reset threshold level is applied
         Note: For full details about BOR characteristics, refer to the “Electrical characteristics” section
         in the device datasheet.
        */
        alias BOR_LEV = BitField!(3, 2, Mutability.rw);

        /********************************************************************************
         Option start 
         This bit triggers a user option operation when set. It is set only by software and cleared when
         the BSY bit is cleared.
        */
        alias OPTSTRT = Bit!(1, Mutability.rs);

        /********************************************************************************
         Option lock 
         Write to 1 only. When this bit is set, it indicates that the FLASH_OPTCR register is locked.
         This bit is cleared by hardware after detecting the unlock sequence.
         In the event of an unsuccessful unlock operation, this bit remains set until the next reset.
        */
        alias OPTLOCK = Bit!(0, Mutability.rs);

    }
}