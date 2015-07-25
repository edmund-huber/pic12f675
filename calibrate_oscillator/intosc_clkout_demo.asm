    processor 12F675
    org 0

; See "Section 27. Device Configuration Bits" of the "PICmicro™ Mid-Range MCU
; Family Reference Manual"
; (http://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf).

; _INTRC_OSC_CLKOUT: we want to use the internal oscillator to drive the PIC,
; so that we don't need to connect a crystal, see "Section 2. Oscillator". Also
; want the clock/4 on pin 3.

    #include <p12f675.inc>
    __config _INTRC_OSC_CLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF

    errorlevel -302

    ; Turn GP5 into a digital output.
    bsf STATUS, RP0
    bcf TRISIO, 5

    ; Toggle GP5 forever.
    bcf STATUS, RP0
loop
    movlw b'00100000'
    xorwf GPIO, F
    goto loop

    end
