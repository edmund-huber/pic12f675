    processor 12F675
    org 0

HC595_SH_CP EQU 0
HC595_ST_CP EQU 1
HC595_DS EQU 2

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

SHIFT_BIT macro BIT
IF (BIT == 0)
    bcf GPIO, HC595_DS
ELSE
    bsf GPIO, HC595_DS
ENDIF
; The HC595 shifts in from DS on SH_CP low-high transitions.
    bcf GPIO, HC595_SH_CP
    bsf GPIO, HC595_SH_CP
    endm

; 4 unused pins out of the 16.
    SHIFT_BIT 0
    SHIFT_BIT 0
    SHIFT_BIT 0
    SHIFT_BIT 0

; Draw '3'.
    SHIFT_BIT 1 ; anode a
    SHIFT_BIT 1 ; anode b
    SHIFT_BIT 1 ; cathode 2
    SHIFT_BIT 0 ; anode f
    SHIFT_BIT 1 ; anode d
    SHIFT_BIT 1 ; anode g
    SHIFT_BIT 1 ; cathode 4
    SHIFT_BIT 0 ; anode dp
    SHIFT_BIT 1 ; cathode 3
    SHIFT_BIT 1 ; anode c
    SHIFT_BIT 0 ; anode e
    SHIFT_BIT 0 ; cathode 1

; Tick on the storage register clock to copy the shift register in.
    bcf GPIO, HC595_ST_CP
    bsf GPIO, HC595_ST_CP

; Repeat this forever.
    goto loop

    end
