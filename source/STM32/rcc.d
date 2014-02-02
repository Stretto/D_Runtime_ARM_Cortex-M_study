
import mmio;

private immutable uint Address = 0x0 + 0x00003800;

struct CR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x00);
    
    // PLLSAI clock ready flag
    // Set by hardware to indicate that the PLLSAI is locked.
    // 0: PLLSAI unlocked
    // 1: PLLSAI locked
    alias PLLSAIRDY = Bit!(29, Policy.ReadWrite);
    
    // PLLSAI enable
    // Set and cleared by software to enable PLLSAI.
    // Cleared by hardware when entering Stop or Standby mode.
    // 0: PLLSAI OFF
    // 1: PLLSAI ON
    alias Bit!(28, Policy.ReadWrite) PLLISAION;

    // PLLI2S clock ready flag
    // Set by hardware to indicate that the PLLI2S is locked.
    // 0: PLLI2S unlocked
    // 1: PLLI2S locked
    alias Bit!(27, Policy.Read) PLLI2SRDY;

    // PLLI2S enable
    // Set and cleared by software to enable PLLI2S.
    // Cleared by hardware when entering Stop or Standby mode.
    // 0: PLLI2S OFF
    // 1: PLLI2S ON
    alias Bit!(26, Policy.ReadWrite) PLLI2SON;

    // Main PLL (PLL) clock ready flag
    // Set by hardware to indicate that PLL is locked.
    // 0: PLL unlocked
    // 1: PLL locked
    alias Bit!(25, Policy.Read) PLLRDY;

    // Main PLL (PLL) enable
    // Set and cleared by software to enable PLL.
    // Cleared by hardware when entering Stop or Stand by mode. This bit cannot be reset if PLL
    // clock is used as the system clock.
    // 0: PLL OFF
    // 1: PLL ON
    alias Bit!(24, Policy.ReadWrite) PLLON;

    // Clock security system enable and cleared by software to enable the clock security
    // system. When CSSON is set, the clock detector is enabled by hardware when the HSE
    // oscillator is ready, and disabled by hardware if an oscillator failure is detected.
    // 0: Clock security system OFF (Clock detector OFF)
    // 1: Clock security system ON (Clock detector ON if HSE oscillator is stable, OFF if not)
    alias Bit!(19, Policy.ReadWrite) CSSON;

    // HSE clock bypass
    // Set and cleared by software to bypass the oscillator with an external clock. The external
    // clock must be enabled with the HSEON bit, to be used by the device.
    // The HSEBYP bit can be written only if the HSE oscillator is disabled.
    // 0: HSE oscillator not bypassed
    // 1: HSE oscillator bypassed with an external clock
    alias Bit!(18, Policy.ReadWrite) HSEBYP;

    // HSE clock ready flag
    // Set by hardware to indicate that the HSE oscillator is stable. After the HSEON bit is cleared,
    // HSERDY goes low after 6 HSE oscillator clock cycles.
    // 0: HSE oscillator not ready
    // 1: HSE oscillator ready
    alias Bit!(17, Policy.Read) HSERDY;

    // HSE clock enable
    // Set and cleared by software. Cleared by hardware to stop the HSE oscillator
    // when entering Stop or Standby mode. This bit cannot be reset if the HSE oscillator is used
    // directly or indirectly as the system clock.
    // 0: HSE oscillator OFF
    // 1: HSE oscillator ON
    alias Bit!(16, Policy.ReadWrite) HSEON;

    // Internal high-speed clock calibration
    // These bits are initialized automatically at startup.
    alias BitField!(uint, 15, 8, Policy.Read) HSICAL;

    // Internal high-speed clock trimming
    // These bits provide an additional user-programmable trimming value that is added to the
    // HSICAL[7:0] bits. It can be programmed to adjust to variations in voltage and temperature
    // that influence the frequency of the internal HSI RC.
    alias BitField!(uint, 7, 3, Policy.ReadWrite) HSITRIM;

    // Internal high-speed clock ready flag
    // Set by hardware to indicate that the HSI oscillator is stable. After the HSION bit is cleared,
    // HSIRDY goes low after 6 HSI clock cycles.
    // 0: HSI oscillator not ready
    // 1: HSI oscillator ready
    alias Bit!(1, Policy.Read) HSIRDY;

    // Internal high-speed clock enable
    // Set and cleared by software.
    // Set by hardware to force the HSI oscillator ON when leaving the Stop or Standby mode or in
    // case of a failure of the HSE oscillator used directly or indirectly
    // as the system clock. This bit cannot be cleared if the HSI is used directly or indirectly
    // as the system clock.
    // 0: HSI oscillator OFF
    // 1: HSI oscillator ON
    alias Bit!(0, Policy.ReadWrite) HSION;  
}

// This register is used to configure the PLL clock outputs according to the formulas:
// f(VCO clock) = f(PLL clock input) × (PLLN / PLLM)
// f(PLL general clock output) = f(VCO clock) / PLLP
// f(USB OTG FS, SDIO, RNG clock output) = f(VCO clock) / PLLQ
struct PLLCFGR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x04);
    
    // Main PLL (PLL) division factor for USB OTG FS, SDIO and random number generator clock
    // Set and cleared by software to control the frequency of USB OTG FS clock, the random
    // number generatr clock and the SDIO clock. These bits should be written only if PLL is disabled.
    // Caution:
    // The USB OTG FS requires a 48 MHz clock to work correctly. The SDIO and the
    // random number generator need a frequency lower than or equal to 48 MHz to work correctly.
    // USB OTG FS clock frequency = VCO frequency / PLLQ with 2 ≤ PLLQ ≤ 15
    // 0000: PLLQ = 0, wrong configuration
    // 0001: PLLQ = 1, wrong configuration
    // 0010: PLLQ = 2
    // 0011: PLLQ = 3
    // 0100: PLLQ = 4
    // ...
    // 1111: PLLQ = 15
    alias BitField!(uint, 27, 24, Policy.ReadWrite) PLLQ;
    alias Bit!(27, Policy.ReadWrite) PLLQ3;
    alias Bit!(26, Policy.ReadWrite) PLLQ2;
    alias Bit!(25, Policy.ReadWrite) PLLQ1;
    alias Bit!(24, Policy.ReadWrite) PLLQ0;

    // Main PLL(PLL) and audio PLL (PLLI2S) entry clock source
    // Set and cleared by software to select PLL and PLLI2S clock source. This bit can be written
    // only when PLL and PLLI2S are disabled.
    // 0: HSI clock selected as PLL and PLLI2S clock entry
    // 1: HSE oscillator clock selected as PLL and PLLI2S clock entry
    alias Bit!(22, Policy.ReadWrite) PLLSRC;

    //  Main PLL (PLL) division factor for main system clock
    // Set and cleared by software to control the fre quency of the general PLL output clock. These
    // bits can be written only if PLL is disabled.
    // Caution:
    // The software has to set these bits correctly not to exceed 168 MHz on this domain.
    // PLL output clock frequency = VCO frequency / PLLP with PLLP = 2, 4, 6, or 8
    // 00: PLLP = 2
    // 01: PLLP = 4
    // 10: PLLP = 6
    // 11: PLLP = 8
    alias BitField!(uint, 17, 16, Policy.ReadWrite) PLLP;
    alias Bit!(17, Policy.ReadWrite) PLLP1;
    alias Bit!(16, Policy.ReadWrite) PLLP0;

    // Main PLL (PLL) multiplication factor for VCO
    // Set and cleared by software to control the multiplication factor of the VCO. These bits can
    // be written only when PLL is disabled. Only half-word and word accesses are allowed to
    // write these bits.
    // Caution:
    // The software has to set these bits correctly to ensure that the VCO output frequency is
    // between 192 and 432 MHz.
    // VCO output frequency = VCO input frequency × PLLN with 192 ≤ PLLN ≤ 432
    // 000000000: PLLN = 0, wrong configuration
    // 000000001: PLLN = 1, wrong configuration
    // ...
    // 011000000: PLLN = 192
    // ...
    // 110110000: PLLN = 432
    // 110110001: PLLN = 433, wrong configuration
    // ...
    // 111111111: PLLN = 511, wrong configuration
    alias BitField!(uint, 14, 6, Policy.ReadWrite) PLLN;

    // Division factor for the main PLL (PLL) and audio PLL (PLLI2S) input clock
    // Set and cleared by software to divide the PLL and PLLI2S input clock before the VCO.
    // These bits can be written only when the PLL and PLLI2S are disabled.
    // Caution:
    // The software has to set these bits correctly to ensure that the VCO input frequency
    // ranges from 1 to 2 MHz. It is recommended to select a frequency of 2 MHz to limit
    // PLL jitter.
    // VCO input frequency = PLL input clock frequency / PLLM with 2 ≤ PLLM ≤ 63
    // 000000: PLLM = 0, wrong configuration
    // 000001: PLLM = 1, wrong configuration
    // 000010: PLLM = 2
    // 000011: PLLM = 3
    // 000100: PLLM = 4
    // ...
    // 111110: PLLM = 62
    // 111111: PLLM = 63
    alias BitField!(uint, 5, 0, Policy.ReadWrite) PLLM;
    alias Bit!(5, Policy.ReadWrite) PLLM5;
    alias Bit!(4, Policy.ReadWrite) PLLM4;
    alias Bit!(3, Policy.ReadWrite) PLLM3;
    alias Bit!(2, Policy.ReadWrite) PLLM2;
    alias Bit!(1, Policy.ReadWrite) PLLM1;
    alias Bit!(0, Policy.ReadWrite) PLLM0;
}

struct CFGR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x08);
    
    // Microcontroller clock output 2
    // Set and cleared by software. Clock source selection may generate glitches on MCO2. It is
    // highly recommended to configure these bits
    // only after reset before enabling the external oscillators and the PLLs.
    // 00: System clock (SYSCLK) selected
    // 01: PLLI2S clock selected
    // 10: HSE oscillator clock selected
    // 11: PLL clock selected
    alias BitField!(uint, 31, 30, Policy.ReadWrite) MCO2;

    // MCO2 prescaler
    // Set and cleared by software to configure the prescaler of the MCO2. Modification of this
    // prescaler may generate glitches on MCO2. It is highly recommended to change this
    // prescaler only after reset before enabling the external oscillators and the PLLs.
    // 0xx: no division
    // 100: division by 2
    // 101: division by 3
    // 110: division by 4
    // 111: division by 5
    alias BitField!(uint, 29, 27, Policy.ReadWrite) MCO2PRE;

    // MCO1 prescaler
    //Set and cleared by software to configure the prescaler of the MCO1. Modification of this
    // prescaler may generate glitches on MCO1. It is highly recommended to change this
    // prescaler only after reset before enabling the external oscillators and the PLL.
    // 0xx: no division
    // 100: division by 2
    // 101: division by 3
    // 110: division by 4
    // 111: division by 5
    alias BitField!(uint, 26, 24, Policy.ReadWrite) MCO1PRE;

    // I2S clock selection
    // Set and cleared by software. This bit allows to select the I2S clock source between the
    // PLLI2S clock and the external clock. It is highly recommended to change this bit only after
    // reset and before enabling the I2S module.
    // 0: PLLI2S clock used as I2S clock source
    // 1: External clock mapped on the I2S_CKIN pin used as I2S clock source
    alias Bit!(23, Policy.ReadWrite) I2SSRC;

    //  Microcontroller clock output 1
    // Set and cleared by software. Clock source selection may generate glitches on MCO1. It is
    // highly recommended to configure these bits only after reset before enabling the external
    // oscillators and PLL.
    // 00: HSI clock selected
    // 01: LSE oscillator selected
    // 10: HSE oscillator clock selected
    // 11: PLL clock selected
    alias BitField!(uint, 22, 21, Policy.ReadWrite) MCO1;

    // HSE division factor for RTC clock
    // Set and cleared by software to divide the HSE clock input clock to generate a 1 MHz clock
    // for RTC.
    // Caution:
    // The software has to set these bits correctly to ensure that the clock supplied to the
    // RTC is 1 MHz. These bits must be configured if needed before selecting the RTC
    // clock source.
    // 00000: no clock
    // 00001: no clock
    // 00010: HSE/2
    // 00011: HSE/3
    // 00100: HSE/4
    // ...
    // 11110: HSE/30
    // 11111: HSE/31
    alias BitField!(uint, 20, 16, Policy.ReadWrite) RTCPRE;

    // APB high-speed prescaler (APB2)
    // Set and cleared by software to control APB high-speed clock division factor.
    // Caution:
    // The software has to set these bits correctly not to exceed 84 MHz on this domain.
    // The clocks are divided with the new prescaler factor from 1 to 16 AHB cycles after PPRE2 write.
    // 0xx: AHB clock not divided
    // 100: AHB clock divided by 2
    // 101: AHB clock divided by 4
    // 110: AHB clock divided by 8
    // 111: AHB clock divided by 16
    alias BitField!(uint, 15, 13, Policy.ReadWrite) PPRE2;

    // APB Low speed prescaler (APB1)
    // Set and cleared by software to control APB low-speed clock division factor.
    // Caution:
    // The software has to set these bits correctly not to exceed 42 MHz on this domain.
    // The clocks are divided with the new prescaler factor from 1 to 16 AHB cycles after PPRE1 write.
    // 0xx: AHB clock not divided
    // 100: AHB clock divided by 2
    // 101: AHB clock divided by 4
    // 110: AHB clock divided by 8
    // 111: AHB clock divided by 16
    alias BitField!(uint, 12, 10, Policy.ReadWrite) PPRE1;


    // AHB prescaler
    // Set and cleared by software to control AHB clock division factor.
    // Caution:
    // The clocks are divided with the new prescaler factor from 1 to 16 AHB cycles after HPRE write.
    // Caution:
    // The AHB clock frequency must be at least 25 MHz when the Ethernet is used.
    // 0xxx: system clock not divided
    // 1000: system clock divided by 2
    // 1001: system clock divided by 4
    // 1010: system clock divided by 8
    // 1011: system clock divided by 16
    // 1100: system clock divided by 64
    // 1101: system clock divided by 128
    // 1110: system clock divided by 256
    // 1111: system clock divided by 512
    alias BitField!(uint, 7, 4, Policy.ReadWrite) HPRE;

    // System clock switch status
    // Set and cleared by hardware to indicate which clock source is used as the system clock.
    // 00: HSI oscillator used as the system clock
    // 01: HSE oscillator used as the system clock
    // 10: PLL used as the system clock
    // 11: not applicable
    alias BitField!(uint, 3, 2, Policy.Read) SWS;
    alias Bit!(3, Policy.Read) SWS1;
    alias Bit!(2, Policy.Read) SWS0;

    // System clock switch
    // Set and cleared by software to select the system clock source.
    // Set by hardware to force the HSI selection when leaving the Stop or Standby mode or in
    // case of failure of the HSE oscillator used directly or indirectly as the system clock.
    // 00: HSI oscillator selected as system clock
    // 01: HSE oscillator selected as system clock
    // 10: PLL selected as system clock
    // 11: not allowed
    alias BitField!(uint, 1, 0, Policy.ReadWrite) SW;
    alias Bit!(1, Policy.ReadWrite) SW1;
    alias Bit!(0, Policy.ReadWrite) SW0;
}

struct CIR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x0C);
    
    //  Clock security system interrupt clear
    // This bit is set by software to clear the CSSF flag.
    // 0: No effect
    // 1: Clear CSSF flag
    alias Bit!(23, Policy.Write) CSSC;

    // PLLSAI Ready Interrupt Clear
    // This bit is set by software to clear PLLSAI RDYF flag. It is reset by hardware when the
    // PLLSAIRDYF is cleared.
    // 0: PLLSAIRDYF not cleared
    // 1: PLLSAIRDYF cleared
    alias Bit!(22, Policy.Write) PLLSAIRDYC;

    // PLLI2S ready interrupt clear
    //This bit is set by software to clear the PLLI2SRDYF flag.
    // 0: No effect
    // 1: PLLI2SRDYF cleared
    alias Bit!(21, Policy.Write) PLLI2SRDYC;

    // Main PLL(PLL) ready interrupt clear
    // This bit is set by software to clear the PLLRDYF flag.
    // 0: No effect
    // 1: PLLRDYF cleared
    alias Bit!(20, Policy.Write) PLLRDYC;

    // HSE ready interrupt clear
    // This bit is set by software to clear the HSERDYF flag.
    // 0: No effect
    // 1: HSERDYF cleared
    alias Bit!(19, Policy.Write) HSERDYC;

    // HSI ready interrupt clear
    // This bit is set software to clear the HSIRDYF flag.
    // 0: No effect
    // 1: HSIRDYF cleared
    alias Bit!(18, Policy.Write) HSIRDYC;

    // LSE ready interrupt clear
    // This bit is set by software to clear the LSERDYF flag.
    // 0: No effect
    // 1: LSERDYF cleared
    alias Bit!(17, Policy.Write) LSERDYC;

    // LSI ready interrupt clear
    // This bit is set by software to clear the LSIRDYF flag.
    // 0: No effect
    // 1: LSIRDYF cleared
    alias Bit!(16, Policy.Write) LSIRDYC;


    // PLLSAI Ready Interrupt Enable
    // This bit is set and reset by software to enable/disable interrupt caused by PLLSAI lock.
    // 0: PLLSAI lock interrupt disabled
    // 1: PLLSAI lock interrupt enabled
    alias Bit!(14, Policy.ReadWrite) PLLSAIRDYIE;

    // PLLI2S ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by PLLI2S lock.
    // 0: PLLI2S lock interrupt disabled
    // 1: PLLI2S lock interrupt enable
    alias Bit!(13, Policy.ReadWrite) PLLI2SRDYIE;

    // Main PLL (PLL) ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by PLL lock.
    // 0: PLL lock interrupt disabled
    // 1: PLL lock interrupt enabled
    alias Bit!(12, Policy.ReadWrite) PLLRDYIE;

    // HSE ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by the HSE
    // oscillator stabilization.
    // 0: HSE ready interrupt disabled
    // 1: HSE ready interrupt enabled
    alias Bit!(11, Policy.ReadWrite) HSERDYIE;

    // HSI ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by the HSI
    // oscillator stabilization.
    // 0: HSI ready interrupt disabled
    // 1: HSI ready interrupt enabled
    alias Bit!(10, Policy.ReadWrite) HSIRDYIE;

    // LSE ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by the LSE
    // oscillator stabilization.
    // 0: LSE ready interrupt disabled
    // 1: LSE ready interrupt enabled
    alias Bit!(9, Policy.ReadWrite) LSERDYIE;

    // LSI ready interrupt enable
    // This bit is set and cleared by software to enable/disable interrupt caused by LSI oscillator
    // stabilization.
    // 0: LSI ready interrupt disabled
    // 1: LSI ready interrupt enabled
    alias Bit!(8, Policy.ReadWrite) LSIRDYIE;

    // Clock security system interrupt flag
    // This bit is set by hardware when a failure is detected in the HSE oscillator.
    // It is cleared by software by setting the CSSC bit.
    // 0: No clock security interrupt caused by HSE clock failure
    // 1: Clock security interrupt caused by HSE clock failure
    alias Bit!(7, Policy.Read) CSSF;

    // PLLSAI Ready Interrupt flag
    // This bit is set by hardware when the PLLSAI is locked and PLLSAIRDYDIE is set.
    // It is cleared by software by setting the PLLSAIRDYC bit.
    // 0: No clock ready interrupt caused by PLLSAI lock
    // 1: Clock ready interrupt caused by PLLSAI lock
    alias Bit!(6, Policy.Read) PLLSAIRDYF;

    // PLLI2S ready interrupt flag
    // This bit is set by hardware when the PLLI2S is locked and PLLI2SRDYDIE is set.
    // It is cleared by software by setting the PLLRI2SDYC bit.
    // 0: No clock ready interrupt caused by PLLI2S lock
    // 1: Clock ready interrupt caused by PLLI2S lock
    alias Bit!(5, Policy.Read) PLLI2SRDYF;

    // Main PLL (PLL) ready interrupt flag
    // This bit is set by hardware when PLL is locked and PLLRDYDIE is set.
    // It is cleared by software setting the PLLRDYC bit.
    // 0: No clock ready interrupt caused by PLL lock
    // 1: Clock ready interrupt caused by PLL lock
    alias Bit!(4, Policy.Read) PLLRDYF;

    // HSE ready interrupt flag
    // This bit is set by hardware when External High Speed clock becomes stable and
    // HSERDYDIE is set.
    // It is cleared by software by setting the HSERDYC bit.
    // 0: No clock ready interrupt caused by the HSE oscillator
    // 1: Clock ready interrupt caused by the HSE oscillato
    alias Bit!(3, Policy.Read) HSERDYF;

    // HSI ready interrupt flag
    // This bit is set by hardware when the Internal High Speed clock becomes stable and
    // HSIRDYDIE is set. It is cleared by software by setting the HSIRDYC bit.
    // 0: No clock ready interrupt caused by the HSI oscillator
    // 1: Clock ready interrupt caused by the HSI oscillator
    alias Bit!(2, Policy.Read) HSIRDYF;

    // LSE ready interrupt flag
    // This bit is set by hardware when the External Low Speed clock becomes stable and
    // LSERDYDIE is set.
    // It is cleared by software by setting the LSERDYC bit.
    // 0: No clock ready interrupt caused by the LSE oscillator
    // 1: Clock ready interrupt caused by the LSE oscillator
    alias Bit!(1, Policy.Read) LSERDYF;

    // LSI ready interrupt flag
    // This bit is set by hardware when the internal low speed clock becomes stable and
    // LSIRDYDIE is set.
    // It is cleared by software by setting the LSIRDYC bit.
    // 0: No clock ready interrupt caused by the LSI oscillator
    // 1: Clock ready interrupt caused by the LSI oscillator
    alias Bit!(0, Policy.Read) LSIRDYF;
}

struct AHB1ENR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x30);
    
    // USB OTG HSULPI clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(30, Policy.ReadWrite) OTGHSULPIEN;

    // USB OTG HS clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(29, Policy.ReadWrite) OTGHSEN;

    // Ethernet PTP clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(28, Policy.ReadWrite) ETHMACPTPEN;

    // Ethernet Reception clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(27, Policy.ReadWrite) ETHMACRXEN;

    // Ethernet Transmission clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(26, Policy.ReadWrite) ETHMACTXEN;

    // Ethernet MAC clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(25, Policy.ReadWrite) ETHMACEN;


    // DMA2 clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(22, Policy.ReadWrite) DMA2EN;

    // DMA1 clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(21, Policy.ReadWrite) DMA1EN;

    // CCM data RAM clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(20, Policy.ReadWrite) CCMDATARAMEN;

    // Backup SRAM interface clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(18, Policy.ReadWrite) BKPSRAMEN;


    // CRC clock enable
    // 0: Disable
    // 1: Enable
    alias Bit!(12, Policy.ReadWrite) CRCEN;
}

struct AHB3ENR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x38);
    
    // 0: Disable
    // 1: Enable
    alias Bit!(0, Policy.ReadWrite) FSMCEN;
}

struct APB1ENR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x40);
    
    // 0: Disable
    // 1: Enable
    alias Bit!(29, Policy.ReadWrite) DACEN;

    // 0: Disable
    // 1: Enable
    alias Bit!(28, Policy.ReadWrite) PWREN;

    // 0: Disable
    // 1: Enable
    alias Bit!(26, Policy.ReadWrite) CAN2EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(25, Policy.ReadWrite) CAN1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(23, Policy.ReadWrite) I2C3EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(22, Policy.ReadWrite) I2C2EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(21, Policy.ReadWrite) I2C1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(20, Policy.ReadWrite) UART5EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(19, Policy.ReadWrite) UART4EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(18, Policy.ReadWrite) USART3EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(17, Policy.ReadWrite) USART2EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(15, Policy.ReadWrite) SPI3EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(14, Policy.ReadWrite) SPI2EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(11, Policy.ReadWrite) WWDGEN;

    // 0: Disable
    // 1: Enable
    alias Bit!(8, Policy.ReadWrite) TIM14EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(7, Policy.ReadWrite) TIM13EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(6, Policy.ReadWrite) TIM12EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(5, Policy.ReadWrite) TIM7EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(4, Policy.ReadWrite) TIM6EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(3, Policy.ReadWrite) TIM5EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(2, Policy.ReadWrite) TIM4EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(1, Policy.ReadWrite) TIM3EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(0, Policy.ReadWrite) TIM2EN;
}

struct APB2ENR
{ 
    // Address 0x2000_1000 is chosen as an arbitrary location in SRAM that's not being used
    mixin Register!(Address + 0x44);
    
    // 0: Disable
    // 1: Enable
    alias Bit!(26, Policy.ReadWrite) LTDCEN;

    // 0: Disable
    // 1: Enable
    alias Bit!(22, Policy.ReadWrite) SAI1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(21, Policy.ReadWrite) SPI6EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(20, Policy.ReadWrite) SPI5EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(18, Policy.ReadWrite) TIM11EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(17, Policy.ReadWrite) TIM10EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(16, Policy.ReadWrite) TIM9EN;


    // 0: Disable
    // 1: Enable
    alias Bit!(14, Policy.ReadWrite) SYSCFGEN;

    // 0: Disable
    // 1: Enable
    alias Bit!(13, Policy.ReadWrite) SPI4EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(12, Policy.ReadWrite) SPI1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(11, Policy.ReadWrite) SDIOEN;

    // 0: Disable
    // 1: Enable
    alias Bit!(10, Policy.ReadWrite) ADC3EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(9, Policy.ReadWrite) ADC2EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(8, Policy.ReadWrite) ADC1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(5, Policy.ReadWrite) USART6EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(4, Policy.ReadWrite) USART1EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(1, Policy.ReadWrite) TIM8EN;

    // 0: Disable
    // 1: Enable
    alias Bit!(0, Policy.ReadWrite) TIM1EN;
}