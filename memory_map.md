#### Example

```
	org $200
	sei 		; disable IRQ
			; set new IRQ 
	lda #<irq_routine
	sta 0x010e 
	lda #>irq_routine 
	sta 0x010f 
			; set video page to $4000
	lda #$4		
	sta 0x0100 
			; enable IRQ
	cli

infinite:
	jmp infinite

irq_routine:
	;	fill the top 4 lines with all the colors 
	ldx #$00 
@xloop
	txa 
	sta $4000,x 
	dex 
	bne @xloop
	rti	

```
#### Notes

CPU boot address is ``0x0200`` always.

#####IRQ vector is located at 0x010E  ( not 0xFFFE like normal 6502)

AUDIO is a simulation of the NES APU ( note REGISTERS are relocated ) 
https://wiki.nesdev.com/w/index.php/APU

#### Memory

| Address       | Size   | Name                   | Description              										|
| --------------|--------|------------------------|---------------------------------------------|
| 0x0000-0x00FF | 0x0100 | Zero Page              |      																				|
| 0x0100-0x0130 | 0x0030 | IO_block               |																							|
| 0x0100        | 0x0001 | Display 								| Select 4kb block for display 0x00-0x0F	 		|
| 0x0101        | 0x0001 | Palette pointer	 	 	  | Select 256 byte block for colors 0x00-0xFF	|
| 0x0102        | 0x0002 | input         	 	 	  	| Keyboard input 															|
| 0x010C-0x010D | 0x0002 | NMI vector    	 	 	  	| called with keyboard input							 		|
| 0x010E-0x010F | 0x0002 | IRQ vector    	 	 	  	| if enabled, called at the end of a frame 		|

| Audio        	| Size   | Name                   | Description		              								|
| --------------|--------|------------------------|---------------------------------------------|
| 0x0104       	| 0x0001 | DPCM sample block	 	  | DPCM sample memory 0x00-0xFF base address		|
| 							| 			 |  											|																							|
| 0x0130-0x0200 | 0x00D0 | Stack                  | Stack pointer starts at 0x01ff  						|
| 0x0200-0xFFFF | 0xFFFF | - Free to use -        | 63 KiB 																			|

#### Video

##### Pixels
Video memory is a simple 64x64 pixel framebuffer with 8 bits per pixel.
This buffer can be located on any 4kb page inside the computer RAM.

##### Colors 
If Palette register is > 0x02 we treat that as the high byte of the lookup 
address. which contains 256 * 3 bytes for R8G8B8. 
*note*
Adjusting these values will ONLY take affect at the end of the frame. ( no raster tricks )

#### Audio

https://wiki.nesdev.com/w/index.php/APU Registers relocated to 0x0110-0x130

| AUDIO | | |
| -------|-------|-------|
| Square 1 | | | |
|0x0110 |DDLC NNNN	Duty| loop envelope/disable length counter, constant volume, envelope period/volume |
|0x0111 |EPPP NSSS|	Sweep unit: enabled, period, negative, shift count |
|0x0112|LLLL LLLL|	Timer low
|0x0113|LLLL LHHH|	Length counter load, timer high (also resets duty and starts envelope)
| ||||
| Square 2 | | | |
|0x0114|	DDLC NNNN|	Duty, loop envelope/disable length counter, constant volume, envelope period/volume|
|0x0115|	EPPP NSSS|	Sweep unit: enabled, period, negative, shift count|
|0x0116|	LLLL LLLL|	Timer low|
|0x0117|	LLLL LHHH	|Length counter load, timer high (also resets duty and starts envelope)|
| |||| 
| Triangle | | | |
| ||||
|0x0118	|CRRR RRRR|	Length counter disable/linear counter control, linear counter reload value|
|0x011A	|LLLL LLLL|	Timer low|
|0x011B	|LLLL LHHH|	Length counter load, timer high (also reloads linear counter)|
| |||| 
|Noise channel | | | |
|0x011C|	--LC NNNN|	Loop envelope/disable length counter, constant volume, envelope period/volume
|0x011E|	L--- PPPP|	Loop noise, noise period
|0x011F|	LLLL L---|	Length counter load (also starts envelope)
| ||||
|DMC | | | |
|0x0120|	IL-- FFFF|	IRQ enable, loop sample, frequency index|
|0x0121|	-DDD DDDD|	Direct load|
|0x0122|	AAAA AAAA|	Sample address %11AAAAAA.AA000000|
|0x0123|	LLLL LLLL|	Sample length %0000LLLL.LLLL0001|
|0x0125	|---D NT21|	Control: DMC enable, length counter enables: noise, triangle, pulse 2, pulse 1 (write)|
|0x0125	|IF-D NT21|	Status: DMC interrupt, frame interrupt, length counter status: noise, triangle, pulse 2, pulse 1 (read)|
