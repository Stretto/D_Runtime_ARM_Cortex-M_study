module pwr;

import bus;

/****************************************************************************************
 Power controller
*/
final abstract class PWR : Peripheral!(APB1, 0x00007000)
{
    /************************************************************************************
     PWR power control register
    */
    final abstract class CR : Register!(0x00, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         Regulator voltage scaling output selection 
         This bit controls the main internal voltage regulator output voltage to achieve a trade-off
         between performance and power consumption when the device does not operate at the
         maximum frequency.
         0: Scale 2 mode
         1: Scale 1 mode (default value at reset)
        */
        alias VOS = Bit!(14, Mutability.rw);

        /********************************************************************************
         Flash power-down in Stop mode 
         When set, the Flash memory enters power-down mode when the device enters Stop mode.
         This allows to achieve a lower consumption in stop mode but a longer restart time.
         0: Flash memory not in power-down when the device is in Stop mode
         1: Flash memory in power-down when the device is in Stop mode
        */
        alias FPDS = Bit!(9, Mutability.rw);

        /********************************************************************************
         Disable backup domain write protection 
         In reset state, the RCC_BDCR register, the RTC registers (including the backup registers),
         and the BRE bit of the PWR_CSR register, are protected against parasitic write access. This
         bit must be set to enable write access to these registers.
         0: Access to RTC and RTC Backup registers and backup SRAM disabled
         1: Access to RTC and RTC Backup registers and backup SRAM enabled
        */
        alias DBP = Bit!(8, Mutability.rw);

        /********************************************************************************
         PVD level selection 
         These bits are written by software to select the voltage threshold detected by the Power
         Voltage Detector
         000: 2.0 V
         001: 2.1 V
         010: 2.3 V
         011: 2.5 V
         100: 2.6 V
         101: 2.7 V
         110: 2.8 V
         111: 2.9 V
         Note: Refer to the electrical characteristics of the datasheet for more details.
        */
        alias PLS[2:0] = BitField!(7, 5, Mutability.rw);

        /********************************************************************************
         Power voltage detector enable 
         This bit is set and cleared by software.
         0: PVD disabled
         1: PVD enabled
        */
        alias PVDE = Bit!(4, Mutability.rw);

        /********************************************************************************
         Clear standby flag 
         This bit is always read as 0.
         0: No effect
         1: Clear the SBF Standby Flag (write).
        */
        alias CSBF = Bit!(3, Mutability.w);

        /********************************************************************************
         Clear wakeup flag 
         This bit is always read as 0.
         0: No effect
         1: Clear the WUF Wakeup Flag after 2 System clock cycles
        */
        alias CWUF = Bit!(2, Mutability.w);

        /********************************************************************************
         Power-down deepsleep 
         This bit is set and cleared by software. It works together with the LPDS bit.
         0: Enter Stop mode when the CPU enters deepsleep. The regulator status depends on the
         LPDS bit.
         1: Enter Standby mode when the CPU enters deepsleep.
        */
        alias PDDS = Bit!(1, Mutability.rw);

        /********************************************************************************
         Low-power deepsleep 
         This bit is set and cleared by software. It works together with the PDDS bit.
         0: Voltage regulator on during Stop mode
         1: Voltage regulator in low-power mode during Stop mode
        */
        alias LPDS = Bit!(0, Mutability.rw);

    }
    /************************************************************************************
     PWR power control/status register
     Additional APB cycles are needed to read this register versus a standard APB read.
    */
    final abstract class CSR : Register!(0x04, Access.Byte_HalfWord_Word)
    {
        /********************************************************************************
         Regulator voltage scaling output selection ready bit 
         0: Not ready
         1: Ready
        */
        alias VOSRDY = Bit!(14, Mutability.r);

        /********************************************************************************
         Backup regulator enable 
         When set, the Backup regulator (used to maintain backup SRAM content in Standby and
         VBAT modes) is enabled. If BRE is reset, the backup regulator is switched off. The backup
         SRAM can still be used but its content will be lost in the Standby and VBAT modes. Once set,
         the application must wait that the Backup Regulator Ready flag (BRR) is set to indicate that
         the data written into the RAM will be maintained in the Standby and VBAT modes.
         0: Backup regulator disabled
         1: Backup regulator enabled
         Note: This bit is not reset when the device wakes up from Standby mode, by a system reset,
         or by a power reset.
        */
        alias BRE = Bit!(9, Mutability.rw);

        /********************************************************************************
         Enable WKUP pin 
         This bit is set and cleared by software.
         0: WKUP pin is used for general purpose I/O. An event on the WKUP pin does not wakeup
         the device from Standby mode.
         1: WKUP pin is used for wakeup from Standby mode and forced in input pull down
         configuration (rising edge on WKUP pin wakes-up the system from Standby mode).
         Note: This bit is reset by a system reset.
        */
        alias EWUP = Bit!(8, Mutability.rw);

        /********************************************************************************
         Backup regulator ready 
         Set by hardware to indicate that the Backup Regulator is ready.
         0: Backup Regulator not ready
         1: Backup Regulator ready
         Note: This bit is not reset when the device wakes up from Standby mode or by a system reset
         or power reset.
        */
        alias BRR = Bit!(3, Mutability.r);

        /********************************************************************************
         PVD output 
         This bit is set and cleared by hardware. It is valid only if PVD is enabled by the PVDE bit.
         0: VDD is higher than the PVD threshold selected with the PLS[2:0] bits.
         1: VDD is lower than the PVD threshold selected with the PLS[2:0] bits.
         Note: The PVD is stopped by Standby mode. For this reason, this bit is equal to 0 after
         Standby or reset until the PVDE bit is set.
        */
        alias PVDO = Bit!(2, Mutability.r);

        /********************************************************************************
         Standby flag 
         This bit is set by hardware and cleared only by a POR/PDR (power-on reset/power-down
         reset) or by setting the CSBF bit in the PWR_CR register.
         0: Device has not been in Standby mode
         1: Device has been in Standby mode
        */
        alias SBF = Bit!(1, Mutability.r);

        /********************************************************************************
         Wakeup flag 
         This bit is set by hardware and cleared either by a system reset or by setting the CWUF bit in
         the PWR_CR register.
         0: No wakeup event occurred
         1: A wakeup event was received from the WKUP pin or from the RTC alarm (Alarm A or
         Alarm B), RTC Tamper event, RTC TimeStamp event or RTC Wakeup).
         Note: An additional wakeup event is detected if the WKUP pin is enabled (by setting the
         EWUP bit) when the WKUP pin level is already high.
        */
        alias WUF = Bit!(0, Mutability.r);

    }
}