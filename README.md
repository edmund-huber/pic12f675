Beginner projects with the PIC12F675: a six-pin 8-bit microcontroller.

Each project contains: gpasm/mpasm -compatible assembler, a circuit diagram,
and a photo of a working breadboard.

I recommend starting from
<https://ehuber.info/blog/pic-development-in-linux.html> to get a grasp for the
very basics such as: the software toolchain (assembler, programmer), the power
circuit, the breadboard.

From simplest to most complicated:
* blink_led: use a digital I/O pin to blink an LED every 1s.
* hc595: use 3 digital I/O pins to control an HC595 SIPO shift register, which in turn drives up to 8 LEDs.
