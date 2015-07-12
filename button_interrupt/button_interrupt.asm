    processor 12F675

    cblock 0x20
        COUNT1
        COUNT2
        COUNT3
        INT_CONTEXT_W
        INT_CONTEXT_STATUS
    endc

    #include <p12f675.inc>
    __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF

    errorlevel -302

    org 0
    goto main

; When any interrupt happens, the PIC will jump to 0x4, the "Interrupt Vector".
; See "Figure 6-1: Architectural Program Memory Map and Stack" of the
; "PICmicro™ Mid-Range MCU Family Reference Manual"
; (http://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf).
    org 0x4

; On an interrupt, the PIC only pushes the PC on the stack. The author is
; responsible for preserving (or not) any other registers, including W and
; STATUS. See "8.5 Context Saving During Interrupts".
    movwf INT_CONTEXT_W
    movf STATUS, W
    movwf INT_CONTEXT_STATUS

; Light up the red LED if the button is pressed and not otherwise.
    bcf STATUS, RP0
    bsf GPIO, GP0
    btfss GPIO, GP2
    bcf GPIO, GP0

; Manually clear the interrupt flag. See "3.2.2 INTERRUPT-ON-CHANGE".
    bcf INTCON, GPIF

; Restore STATUS and W, as discussed.
    movf INT_CONTEXT_STATUS, W
    movwf STATUS
    movf INT_CONTEXT_W, W

; This restores PC from the stack, and re-enables interrupts. This is the end
; of the interrupt handler!
    retfie

main
    bcf STATUS, RP0

; Let pins GP{0,1,2} act as digital I/O pins.
    clrf GPIO

; Disable the comparator, this lets pins GP{0,1,2} act as digital I/O pins.
    movlw b'111'
    movwf CMCON

    bsf STATUS, RP0

; Disable analog circuitry on pins AN{0,1,2,3}.
    bcf ANSEL, ANS0
    bcf ANSEL, ANS1
    bcf ANSEL, ANS2
    bcf ANSEL, ANS3

; We want GP2 to be digital input and the rest of GP0-GP5 to be output.
    movlw b'00000100'
    movwf TRISIO

; Enable interrupt on GP2 port change.
    bsf IOC, IOC2
    bsf INTCON, GPIE
    bsf INTCON, GIE

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

; Toggle the green LED every second.
    movlw b'00000010'
    xorwf GPIO, F

; Repeat this forever.
    goto loop

    end
