/****************************************************************************************
 System Control Block
*/
final abstract class SCB : Peripheral!(0x00000000)
{
    /************************************************************************************
     Auxiliary control register
     By default this register is set to provide optimum performance from the Cortex-M4
     processor, and does not normally require modification. The ACTLR register provides disable
     bits for the following processor functions:
     ● IT folding
     ● write buffer use for accesses to the default memory map
     ● interruption of multi-cycle instructions.
    */
    final abstract class ACTLR : Register!(0x00 (base adress = 0xE000 E008), Access.Word)
    {
        /********************************************************************************
         Disables floating point instructions completing out of order with respect to integer instructions.
        */
        alias DISOOFP = Bit!(9, Mutability.rw);

        /********************************************************************************
         
         Disables automatic update of CONTROL.FPCA.
        */
        alias DISFPCA = Bit!(8, Mutability.rw);

        /********************************************************************************
         
         Disables folding of IT instructions: 
         0: Enables IT instructions folding.
         1: Disables IT instructions folding.
         In some situations, the processor can start executing the first instruction in an IT block while it
         is still executing the IT instruction. This behavior is called IT folding, and improves
         performance, However, IT folding can cause jitter in looping. If a task must avoid jitter, set the
         DISFOLD bit to 1 before executing the task, to disable IT folding.
        */
        alias DISFOLD = Bit!(2, Mutability.rw);

        /********************************************************************************
         
         This bit only affects write buffers implemented in the Cortex-M4 processor.
         Disables write buffer use during default memory map accesses: This causes all BusFaults to
         be precise BusFaults but decreases performance because any store to memory must
         complete before the processor can execute the next instruction.
         0: Enable write buffer use: stores to memory is competed before next instruction.
         1: Disable write buffer use.
        */
        alias DISDEFWBUF = Bit!(1, Mutability.rw);

        /********************************************************************************
         
         Disables interrupt of multi-cycle instructions. When set to 1, disables interruption of load
         multiple and store multiple instructions. This increases the interrupt latency of the processor
         because any LDM or STM must complete before the processor can stack the current state and
         enter the interrupt handler.
         0: Enable interruption latency of the processor (load/store and multiply/divide operations).
         1: Disable interruptions latency.
        */
        alias DISMCYCINT = Bit!(0, Mutability.rw);

    }
    /************************************************************************************
     CPUID base register
     The CPUID register contains the processor part number, version, and implementation
     information.
    */
    final abstract class CPUID : Register!(0x00, Access.Word)
    {
        /********************************************************************************
         Implementer code 
         0x41: ARM
        */
        alias Implementer = BitField!(31, 24, Mutability.r);

        /********************************************************************************
         Variant number 
         The r value in the rnpn product revision identifier
         0x0: revision 0
        */
        alias Variant = BitField!(23, 20, Mutability.r);

        /********************************************************************************
         Reads as 0xF 
        */
        alias Constant = BitField!(19, 16, Mutability.r);

        /********************************************************************************
         Part number of the processor 
         0xC24: = Cortex-M4
        */
        alias PartNo = BitField!(15, 4, Mutability.r);

        /********************************************************************************
         Revision number 
         The p value in the rnpn product revision identifier, indicates patch release.
         0x1: = patch 1
        */
        alias Revision = BitField!(3, 0, Mutability.r);

    }
    /************************************************************************************
     Interrupt control and state register
     The ICSR:
     ● Provides:
     – A set-pending bit for the Non-Maskable Interrupt (NMI) exception
     – Set-pending and clear-pending bits for the PendSV and SysTick exceptions
     ● Indicates:
     – The exception number of the exception being processed
     – Whether there are preempted active exceptions
     – The exception number of the highest priority pending exception
     – Whether any interrupts are pending.
     Caution: When you write to the ICSR, the effect is unpredictable if you:
     ● Write 1 to the PENDSVSET bit and write 1 to the PENDSVCLR bit
     ● Write 1 to the PENDSTSET bit and write 1 to the PENDSTCLR bit.
    */
    final abstract class ICSR : Register!(0x04, Access.Word)
    {
        /********************************************************************************
         NMI set-pending bit. 
         Write:
         0: No effect
         1: Change NMI exception state to pending.
         Read:
         0: NMI exception is not pending
         1: NMI exception is pending
         Because NMI is the highest-priority exception, normally the processor enter the NMI
         exception handler as soon as it registers a write of 1 to this bit, and entering the handler clears
         this bit to 0. A read of this bit by the NMI exception handler returns 1 only if the NMI signal is
         reasserted while the processor is executing that handler.
        */
        alias NMIPENDSET = Bit!(31, Mutability.rw);

        /********************************************************************************
         PendSV set-pending bit. 
         Write:
         0: No effect
         1: Change PendSV exception state to pending.
         Read:
         0: PendSV exception is not pending
         1: PendSV exception is pending
         Writing 1 to this bit is the only way to set the PendSV exception state to pending.
        */
        alias PENDSVSET = Bit!(28, Mutability.rw);

        /********************************************************************************
         PendSV clear-pending bit. This bit is write-only. On a read, value is unknown. 
         0: No effect
         1: Removes the pending state from the PendSV exception.
        */
        alias PENDSVCLR = Bit!(27, Mutability.w);

        /********************************************************************************
         SysTick exception set-pending bit. 
         Write:
         0: No effect
         1: Change SysTick exception state to pending
         Read:
         0: SysTick exception is not pending
         1: SysTick exception is pending
        */
        alias PENDSTSET = Bit!(26, Mutability.rw);

        /********************************************************************************
         SysTick exception clear-pending bit. Write-only. On a read, value is unknown. 
         0: No effect
         1: Removes the pending state from the SysTick exception.
        */
        alias PENDSTCLR = Bit!(25, Mutability.w);

        /********************************************************************************
         bit is reserved for Debug use and reads-as-zero when the processor is not in Debug. 
        */
        alias This = Bit!(23, Mutability.r);

        /********************************************************************************
         Interrupt pending flag, excluding NMI and Faults. 
         0: Interrupt not pending
         1: Interrupt pending
        */
        alias ISRPENDING = Bit!(22, Mutability.r);

        /********************************************************************************
         Pending vector. Indicates the exception number of the highest priority 
         pending enabled exception.
         0: No pending exceptions
         Other values: The exception number of the highest priority pending enabled exception.
         The value indicated by this field includes the effect of the BASEPRI and FAULTMASK
         registers, but not any effect of the PRIMASK register.
        */
        alias VECTPENDING = BitField!(18, 12, Mutability.r);

        /********************************************************************************
         Return to base level. Indicates whether there are preempted active exceptions: 
         0: There are preempted active exceptions to execute
         1: There are no active exceptions, or the currently-executing exception is the only active
         exception.
        */
        alias RETTOBASE = Bit!(11, Mutability.rw);

        /********************************************************************************
         Active vector. Contains the active exception number: 
         0: Thread mode
         Other values: The exception number(1) of the currently active exception.
         Note: Subtract 16 from this value to obtain CMSIS IRQ number required to index into the
         Interrupt Clear-Enable, Set-Enable, Clear-Pending, Set-Pending, or Priority Registers,
         see Table 6 on page 21.
         1. This is the same value as IPSR bits[8:0], see Interrupt program status register on page 21.
        */
        alias VECTACTIVE = BitField!(8, 0, Mutability.rw);

    }
    /************************************************************************************
     Vector table offset register
    */
    final abstract class VTOR : Register!(0x08, Access.Word)
    {
        /********************************************************************************
         Vector table base offset field. 
         It contains bits [29:9] of the offset of the table base from memory address 0x00000000. When
         setting TBLOFF, you must align the offset to the number of exception entries in the vector table.
         The minimum alignment is 128 words. Table alignment requirements mean that bits[8:0] of the
         table offset are always zero.
        */
        alias TBLOFF = BitField!(29, 9, Mutability.rw);

        /********************************************************************************
         whether the vector table is in the code or SRAM memory region. 
         0: Code
         1: SRAM
         Note: Bit 29 is sometimes called the TBLBASE bit.
        */
        alias determines = Bit!(29, Mutability.rw);

    }
    /************************************************************************************
     Application interrupt and reset control register
     The AIRCR provides priority grouping control for the exception model, endian status for data
     accesses, and reset control of the system.
     To write to this register, you must write 0x5FA to the VECTKEY field, otherwise the
     processor ignores the write.
    */
    final abstract class AIRCR : Register!(0x0C, Access.Word)
    {
        /********************************************************************************
         VECTKEY Register key 
         Reads as 0xFA05
         On writes, write 0x5FA to VECTKEY, otherwise the write is ignored.
        */
        alias VECTKEYSTAT = BitField!(31, 16, Mutability.rw);

        /********************************************************************************
         Data endianness bit 
         Reads as 0.
         0: Little-endian
        */
        alias ENDIANESS = Bit!(15, Mutability.r);

        /********************************************************************************
         Interrupt priority grouping field 
         This field determines the split of group priority from subpriority, see Binary point on page 212.
        */
        alias PRIGROUP = BitField!(10, 8, Mutability.rw);

        /********************************************************************************
         System reset request 
         This is intended to force a large system reset of all major components except for debug.
         This bit reads as 0.
         0: No system reset request
         1: Asserts a signal to the outer system that requests a reset.
        */
        alias SYSRESETREQ = Bit!(2, Mutability.w);

        /********************************************************************************
         
         Reserved for Debug use. This bit reads as 0. When writing to the register you must write 0 to
         this bit, otherwise behavior is unpredictable.
        */
        alias VECTCLRACTIVE = Bit!(1, Mutability.w);

        /********************************************************************************
         
         Reserved for Debug use. This bit reads as 0. When writing to the register you must write 0 to
         this bit, otherwise behavior is unpredictable.
        */
        alias VECTRESET = Bit!(0, Mutability.w);

    }
    /************************************************************************************
     System control register
     The SCR controls features of entry to and exit from low power state.
    */
    final abstract class SCR : Register!(0x10, Access.Word)
    {
        /********************************************************************************
         Send Event on Pending bit 
         When an event or interrupt enters pending state, the event signal wakes up the processor from
         WFE. If the processor is not waiting for an event, the event is registered and affects the next
         WFE.
         The processor also wakes up on execution of an SEV instruction or an external event
         0: Only enabled interrupts or events can wakeup the processor, disabled interrupts are
         excluded
         1: Enabled events and all interrupts, including disabled interrupts, can wakeup the
         processor.
        */
        alias SEVEONPEND = Bit!(4, Mutability.rw);

        /********************************************************************************
         
         Controls whether the processor uses sleep or deep sleep as its low power mode:
         0: Sleep
         1: Deep sleep.
        */
        alias SLEEPDEEP = Bit!(2, Mutability.rw);

        /********************************************************************************
         
         Configures sleep-on-exit when returning from Handler mode to Thread mode. Setting this bit to
         1 enables an interrupt-driven application to avoid returning to an empty main application.
         0: Do not sleep when returning to Thread mode.
         1: Enter sleep, or deep sleep, on return from an interrupt service routine.
        */
        alias SLEEPONEXIT = Bit!(1, Mutability.rw);

    }
    /************************************************************************************
     Configuration and control register
     The CCR controls entry to Thread mode and enables:
     ● The handlers for NMI, hard fault and faults escalated by FAULTMASK to ignore bus
     faults
     ● Trapping of divide by zero and unaligned accesses
     ● Access to the STIR by unprivileged software, see Software trigger interrupt register
     (NVIC_STIR) on page 202.
    */
    final abstract class CCR : Register!(0x14, Access.Word)
    {
        /********************************************************************************
         
         Configures stack alignment on exception entry. On exception entry, the processor uses bit 9 of
         the stacked PSR to indicate the stack alignment. On return from the exception it uses this
         stacked bit to restore the correct stack alignment.
         0: 4-byte aligned
         1: 8-byte aligned
        */
        alias STKALIGN = Bit!(9, Mutability.rw);

        /********************************************************************************
         
         Enables handlers with priority -1 or -2 to ignore data bus faults caused by load and store
         instructions. This applies to the hard fault, NMI, and FAULTMASK escalated handlers. Set this
         bit to 1 only when the handler and its data are in absolutely safe memory. The normal use of
         this bit is to probe system devices and bridges to detect control path problems and fix them.
         0: Data bus faults caused by load and store instructions cause a lock-up
         1: Handlers running at priority -1 and -2 ignore data bus faults caused by load and store
         instructions.
        */
        alias BFHFNMIGN = Bit!(8, Mutability.rw);

        /********************************************************************************
         
         Enables faulting or halting when the processor executes an SDIV or UDIV instruction with a
         divisor of 0:
         0: Do not trap divide by 0
         1: Trap divide by 0.
         When this bit is set to 0, a divide by zero returns a quotient of 0.
        */
        alias DIV_0_TRP = Bit!(4, Mutability.rw);

        /********************************************************************************
         TRP 
         Enables unaligned access traps:
         0: Do not trap unaligned halfword and word accesses
         1: Trap unaligned halfword and word accesses.
         If this bit is set to 1, an unaligned access generates a usage fault.
         Unaligned LDM, STM, LDRD, and STRD instructions always fault irrespective of whether
         UNALIGN_TRP is set to 1.
        */
        alias UNALIGN = Bit!(3, Mutability.rw);

        /********************************************************************************
         
         Enables unprivileged software access to the STIR, see Software trigger interrupt register
         (NVIC_STIR) on page 202:
         0: Disable
         1: Enable.
        */
        alias USERSETMPEND = Bit!(1, Mutability.rw);

        /********************************************************************************
         
         Configures how the processor enters Thread mode.
         0: Processor can enter Thread mode only when no exception is active.
         1: Processor can enter Thread mode from any level under the control of an EXC_RETURN
         value, see Exception return on page 43.
        */
        alias NONBASETHRDENA = Bit!(0, Mutability.rw);

    }
    /************************************************************************************
     System handler control and state register
     The SHCSR enables the system handlers, and indicates:
     ● The pending status of the bus fault, memory management fault, and SVC exceptions
     ● The active status of the system handlers.
     If you disable a system handler and the corresponding fault occurs, the processor treats the
     fault as a hard fault.
     You can write to this register to change the pending or active status of system exceptions.
     An OS kernel can write to the active bits to perform a context switch that changes the
     current exception type.
     ● Software that changes the value of an active bit in this register without correct
     adjustment to the stacked content can cause the processor to generate a fault
     exception. Ensure software that writes to this register retains and subsequently
     restores the current active status.
     ● After you have enabled the system handlers, if you have to change the value of a bit in
     this register you must use a read-modify-write procedure to ensure that you change
     only the required bit.
    */
    final abstract class SHCSR : Register!(0x24, Access.Word)
    {
        /********************************************************************************
         Usage fault enable bit, set to 1 to enable. 
         Enable bits, set to 1 to enable the exception, or set to 0 to disable the exception.
        */
        alias USGFAULTENA = Bit!(18, Mutability.rw);

        /********************************************************************************
         Bus fault enable bit, set to 1 to enable. 
         Enable bits, set to 1 to enable the exception, or set to 0 to disable the exception.
        */
        alias BUSFAULTENA = Bit!(17, Mutability.rw);

        /********************************************************************************
         Memory management fault enable bit, set to 1 to enable. 
         Enable bits, set to 1 to enable the exception, or set to 0 to disable the exception.
        */
        alias MEMFAULTENA = Bit!(16, Mutability.rw);

        /********************************************************************************
         SVC call pending bit, reads as 1 if exception is pending. 
         Pending bits, read as 1 if the exception is pending, or as 0 if it is not pending. You can write to these bits to change the
         pending status of the exceptions.
        */
        alias SVCALLPENDED = Bit!(15, Mutability.rw);

        /********************************************************************************
         Bus fault exception pending bit, reads as 1 if exception is pending. 
         Pending bits, read as 1 if the exception is pending, or as 0 if it is not pending. You can write to these bits to change the
         pending status of the exceptions.
        */
        alias BUSFAULTPENDED = Bit!(14, Mutability.rw);

        /********************************************************************************
         Memory management fault exception pending bit, reads as 1 if 
         exception is pending.
         Pending bits, read as 1 if the exception is pending, or as 0 if it is not pending. You can write to these bits to change the
         pending status of the exceptions.
        */
        alias MEMFAULTPENDED = Bit!(13, Mutability.rw);

        /********************************************************************************
         Usage fault exception pending bit, reads as 1 if exception is pending. 
         Pending bits, read as 1 if the exception is pending, or as 0 if it is not pending. You can write to these bits to change the
         pending status of the exceptions.
        */
        alias USGFAULTPENDED = Bit!(12, Mutability.rw);

        /********************************************************************************
         SysTick exception active bit, reads as 1 if exception is active. 
         Active bits, read as 1 if the exception is active, or as 0 if it is not active. You can write to these bits to change the active
         status of the exceptions, but see the Caution in this section.
        */
        alias SYSTICKACT = Bit!(11, Mutability.rw);

        /********************************************************************************
         PendSV exception active bit, reads as 1 if exception is active 
        */
        alias PENDSVACT = Bit!(10, Mutability.rw);

        /********************************************************************************
         Debug monitor active bit, reads as 1 if Debug monitor is active 
        */
        alias MONITORACT = Bit!(8, Mutability.rw);

        /********************************************************************************
         SVC call active bit, reads as 1 if SVC call is active 
        */
        alias SVCALLACT = Bit!(7, Mutability.rw);

        /********************************************************************************
         Usage fault exception active bit, reads as 1 if exception is active 
        */
        alias USGFAULTACT = Bit!(3, Mutability.rw);

        /********************************************************************************
         Bus fault exception active bit, reads as 1 if exception is active 
        */
        alias BUSFAULTACT = Bit!(1, Mutability.rw);

        /********************************************************************************
         Memory management fault exception active bit, reads as 1 if exception is 
         active
        */
        alias MEMFAULTACT = Bit!(0, Mutability.rw);

    }
    /************************************************************************************
     Hard fault status register
     The HFSR gives information about events that activate the hard fault handler. This register
     is read, write to clear. This means that bits in the register read normally, but writing 1 to any
     bit clears that bit to 0.
    */
    final abstract class HFSR : Register!(0x2C, Access.Word)
    {
        /********************************************************************************
         Reserved for Debug use. When writing to the register you must write 0 to this bit, 
         otherwise behavior is unpredictable.
        */
        alias DEBUG_VT = Bit!(31, Mutability.rc_w1);

        /********************************************************************************
         Forced hard fault. Indicates a forced hard fault, generated by escalation of a fault 
         with configurable priority that cannot be handles, either because of priority or because it is
         disabled.
         When this bit is set to 1, the hard fault handler must read the other fault status registers to find
         the cause of the fault.
         0: No forced hard fault
         1: Forced hard fault.
        */
        alias FORCED = Bit!(30, Mutability.rc_w1);

        /********************************************************************************
         Vector table hard fault. Indicates a bus fault on a vector table read during exception 
         processing. This error is always handled by the hard fault handler.
         When this bit is set to 1, the PC value stacked for the exception return points to the instruction
         that was preempted by the exception.
         0: No bus fault on vector table read
         1: Bus fault on vector table read.
        */
        alias VECTTBL = Bit!(1, Mutability.rc_w1);

    }
    /************************************************************************************
     Memory management fault address register
    */
    final abstract class MMFAR : Register!(0x34, Access.Word)
    {
        /********************************************************************************
         Memory management fault address 
         When the MMARVALID bit of the MMFSR is set to 1, this field holds the address of the
         location that generated the memory management fault.
         When an unaligned access faults, the address is the actual address that faulted. Because a
         single read or write instruction can be split into multiple aligned accesses, the fault address
         can be any address in the range of the requested access size.
         Flags in the MMFSR register indicate the cause of the fault, and whether the value in the
         MMFAR is valid. See Configurable fault status register (CFSR; UFSR+BFSR+MMFSR) on
         page 220.
        */
        alias MMFAR = BitField!(31, 0, Mutability.rw);

    }
    /************************************************************************************
     Bus fault address register
    */
    final abstract class BFAR : Register!(0x38, Access.Word)
    {
        /********************************************************************************
         Bus fault address 
         When the BFARVALID bit of the BFSR is set to 1, this field holds the address of the location
         that generated the bus fault.
         When an unaligned access faults the address in the BFAR is the one requested by the
         instruction, even if it is not the address of the fault.
         Flags in the BFSR register indicate the cause of the fault, and whether the value in the BFAR
         is valid. See Configurable fault status register (CFSR; UFSR+BFSR+MMFSR) on page 220.
        */
        alias BFAR = BitField!(31, 0, Mutability.rw);

    }
    /************************************************************************************
     Auxiliary fault status register
    */
    final abstract class AFSR : Register!(0x3C, Access.Word)
    {
        /********************************************************************************
         Implementation defined. The AFSR contains additional system fault information. The 
         bits map to the AUXFAULT input signals.
         This register is read, write to clear. This means that bits in the register read normally, but
         writing 1 to any bit clears that bit to 0.
         Each AFSR bit maps directly to an AUXFAULT input of the processor, and a single-cycle HIGH
         signal on the input sets the corresponding AFSR bit to one. It remains set to 1 until you write 1
         to the bit to clear it to zero.
         When an AFSR bit is latched as one, an exception does not occur. Use an interrupt if an
         exception is required.
        */
        alias IMPDEF = BitField!(31, 0, Mutability.rw);

    }
    /************************************************************************************
     Coprocessor access control register
     The CPACR register specifies the access privileges for coprocessors.
    */
    final abstract class CPACR : Register!(0x88, Access.Word)
    {
        /********************************************************************************
         [2n+1:2n] for n values 10 and 11. Access privileges for coprocessor n. The possible 
         values of each field are:
         0b00: Access denied. Any attempted access generates a NOCP UsageFault.
         0b01: Privileged access only. An unprivileged access generates a NOCP fault.
         0b10: Reserved. The result of any access is Unpredictable.
         0b11: Full access.
        */
        alias CPn = BitField!(23, 20, Mutability.rw);

    }
}