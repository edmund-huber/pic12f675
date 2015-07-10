    processor 12F675
    org 0

; This shorthand assigns COUNT1=0x20, COUNT2=0x21, etc.
    cblock 0x20
        COUNT1
        COUNT2
        COUNT3
    endc

; See "Section 27. Device Configuration Bits" of the "PICmicro™ Mid-Range MCU
; Family Reference Manual"
; (http://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf).

; _INTRC_OSC_NOCLKOUT: we want to use the internal oscillator to drive the PIC,
; so that we don't need to connect a crystal, see "Section 2. Oscillator".

; _WDT_OFF: disable the watchdog timer, which if enabled would reset the PIC
; every 18ms, see "Section 26. Watchdog Timer and Sleep Mode".
;
; _PWRTE_ON: enable the power-up timer, which instructs the MPU to wait about
; 72ms to give time for Vdd to reach a stable voltage, see "9.3.3 POWER-UP TIMER
; (PWRT)".
;
; _MCLRE_OFF: if "Master Clear" is enabled, pin 4/GP3 is the reset pin, so
; you'd need to supply Vdd on that pin. By disabling this, GP3 becomes available
; for I/O.

    #include <p12f675.inc>
    __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF

; The PIC assembler will warn every time you try to use a register that isn't
; in Bank 0. The warning is annoying and unnecessary.
    errorlevel -302

; See "3.1 GPIO and the TRISIO Registers" in the PIC12F629/675 data sheet. The
; following turns GP0 into an output pin:

; Select Bank 0 of memory by clearing the Register Bank Select bit (RP0) of
; the STATUS register. See "FIGURE 2-2: DATA MEMORY MAP OF THE PIC12F629/675".
    bcf STATUS, RP0

; Set byte at address GPIO in Bank 0 to 0, so that digital pin outputs will be
; a known value (0, low).
    clrf GPIO

; This turns the comparator off, see "FIGURE 6-2: COMPARATOR I/O OPERATING
; MODES". This lets pins GP{0,1,2} act as digital I/O pins.
    movlw b'111'
    movwf CMCON

; Select Bank 1.
    bsf STATUS, RP0

; Disable analog circuitry on pins AN{0,1,2,3}.
    bcf ANSEL, ANS0
    bcf ANSEL, ANS1
    bcf ANSEL, ANS2
    bcf ANSEL, ANS3

; Finally: this turns all pins which can act as digital outputs, into digital
; outputs.
    clrf TRISIO

; (Done!)

; Back to Bank 0 so that we have access to GPIO.
    bcf STATUS, RP0

loop
; Generated cycle-accurate delay code using
; http://www.golovchenko.org/cgi-bin/delay . Since the code was generated using
; the assumption that the clock is exactly 4MHZ, this won't create a delay of
; exactly one second, since the internal oscillator is not tuned that well.

            ;999997 cycles
    movlw   0x08
    movwf   COUNT1
    movlw   0x2F
    movwf   COUNT2
    movlw   0x03
    movwf   COUNT3
Delay_0
    decfsz  COUNT1, f
    goto    $+2
    decfsz  COUNT2, f
    goto    $+2
    decfsz  COUNT3, f
    goto    Delay_0

            ;3 cycles
    goto    $+1
    nop
    movlw 63
    movwf COUNT1

; Toggle the LED every second.
    movlw b'00000001'
    xorwf GPIO, 1

; Repeat this forever.
    goto loop

    end
