    processor 12F675
    org 0

    cblock 0x20
      COUNT1
      COUNT2
      COUNT3
      BITS
      BITS_COPY
    endc
HC595_DS EQU 0
HC595_ST_CP EQU 1
HC595_SH_CP EQU 2

    #include <p12f675.inc>
    __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF

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

; Disable analog circuitry on pins AN{0,1,2,3}.
    bsf STATUS, RP0
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

; The HC595 shifts in from DS on SH_CP low-high transitions.
SHIFT_CLOCK macro
    bcf GPIO, HC595_SH_CP
    bsf GPIO, HC595_SH_CP
    endm

; Increment BITS and copy it.
    incf BITS, F
    movf BITS, W
    movwf BITS_COPY

; Clock the least significant bit of W into the shift register, and rotate
; bits, 3 times.
SHIFT_LSB_AND_CLOCK macro
    bcf GPIO, HC595_DS
    btfsc BITS_COPY, 0
    bsf GPIO, HC595_DS
    SHIFT_CLOCK
    rrf BITS_COPY, F
    endm
    SHIFT_LSB_AND_CLOCK
    SHIFT_LSB_AND_CLOCK
    SHIFT_LSB_AND_CLOCK

; We're not using Q4-Q0, so just clock 5 0's in.
    bcf GPIO, HC595_DS
    SHIFT_CLOCK
    SHIFT_CLOCK
    SHIFT_CLOCK
    SHIFT_CLOCK
    SHIFT_CLOCK

; Tick on the storage register clock to copy the shift register in.
    bcf GPIO, HC595_ST_CP
    bsf GPIO, HC595_ST_CP

; Repeat this forever.
    goto loop

    end
