; we steal some space from the stack
;	no one ever has a stack that big :P
; the control registers are at $100-$130

VIDEO = $100
COLORS = $101
INPUT = $102
AUDIO = $104

;	NOTE NOTE
;	normal 6502 has irq vectors at $fffe
;	we have them at $010e
NMI_IRQ				= $10c
VBLANK_IRQ		= $10e

AUDIO_REGS = $110
AUDIO_VOLUME = $111
AUDIO_CHANNEL1 = $112
AUDIO_CHANNEL2 = $112+4
AUDIO_CHANNEL3 = $112+8
AUDIO_CHANNEL3 = $112+12



; handy macros

MACRO 	_setb value,dest
	lda #value
	sta dest
ENDM

MACRO 	_setw value,dest
	lda #<value
	sta dest
	lda #>value
	sta dest+1
ENDM

MACRO 	_movw value,dest
	lda value
	sta dest
	lda value+1
	sta dest+1
ENDM

MACRO 	_addw	source,addition,dest
	clc
	lda source
	adc addition
	sta dest
	lda source+1
	adc addition+1
	sta dest+1
ENDM


MACRO 	_addwb	source,addition,dest
	clc
	lda source
	adc addition
	sta dest
	lda source+1
	adc #0
	sta dest+1
ENDM

MACRO 	_addwi	source,addition,dest
	clc
	lda source
	adc #<addition
	sta dest
	lda source+1
	adc #>addition
	sta dest+1
ENDM

MACRO _unpack source,destination
	_setw source,apd_src
	_setw destination,apd_dest
	jsr dc64f
ENDM

MACRO _halt
  halt: jmp halt
ENDM
