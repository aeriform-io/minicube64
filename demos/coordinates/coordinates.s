; This program simply draws a diagonal line from x:0 y:0 to x:63 y:63
; I have it set to draw only one pixel per frame.

include "64cube.inc"

MACRO _setVideo page
    lda #$page
    sta VIDEO
    asl
    asl
    asl
    asl
    sta video_page
ENDM

ENUM $0
    xpos          db	0	; x and y coordinates as pure binary values
    ypos          db	0
    video_page 	  db	0	; convenient for conversions to pixel address
    adrL          db	0	; pointer to an actual screen pixel address
    adrH          db	0
ENDE

white EQU $3f

org $200
init:
    sei	; disable interrupts
    ldx #$ff
    txs	; reset stack

    _setVideo 2
    _setw atVblank,VBLANK_IRQ
    
    ; initialize adrL/H based on contents of xpos and ypos
    jsr XYposToScreenAddress

    cli	; allow per-frame interrupts

; loop broken only by interrupts
whileInactiveLoop: 
    jmp whileInactiveLoop

; draw a pixel according to the address held in adrL/H
drawToScreen:
    lda #white
    ldx #0
    sta (adrL, x)
rts

;called once per frame
atVblank:
    jsr drawToScreen

    ; move next potential pixel location down-right
    inc xpos
    inc ypos
    jsr validateXYpos	; prevent drawing outside of the screen
    jsr XYposToScreenAddress	; prepare draw routine's input
    rti

validateXYpos
    ; cmp is sec then A - M (simulated) to set/clear flags NZC
    ; 	sec xpos - 64 = unused carry if xpos >= 64
    ; A:xpos	M:#64
    ; Stop drawing if xpos or ypos >= 64

    lda xpos
    cmp #64
    bcs stopDrawing

    lda ypos
    cmp #64
    bcs stopDrawing
rts

stopDrawing:
    pla	; decrement the stack since it skips returning from subroutine
    sei	; disable interrupts to prevent more vblank interrupts
jmp whileInactiveLoop ; interrupts disabled means it just loops


;  ----------------------------------------------------------------------------------
; |    Binary Magic Needed to Convert Between X/Y Coordinates and Pixel Addresses    |
;  ----------------------------------------------------------------------------------

; The conversion routines could be made a little more readable, but I was going
;	for op code byte/cycle efficiency by writing the output in stages rather
;	than 0-initializing it or using scratch variables for certain parts.

; The main takeaway is that xpos and ypos can be seen in the bits of the screen address.
; To illustrate, adrH and adrL with Xs and Ys on corresponding bits, Ps for video_page:
;		High-Low: PPPP YYYY YYXX XXXX

; Knowing this, we can find xpos by simply masking out the top two adrL bits.
; To get ypos, we have to do some rotating from one byte to another.
; The video_page bits can be discarded when finding x/y coordinates.

; Getting a usable address out of x/y coordinates is a little more tricky.
; Since these on their own can't fill up the entire bit range of either one's
; 	8-bit space, there will be some high 0 bits to contend with.
;      xpos bits: 00xx xxxx
;      ypos bits: 00yy yyyy

; Also, the video page will need to be the topmost nibble to get it on the right screen.
; Nibbles of adrH/L shown high-to-low in significance (big-endian) for readability:
;	Nibble3:  pppp
;	Nibble2:      yyyy
;	Nibble1:          yyxx
;	Nibble0:              xxxx

; So, if #$f was stored in VIDEO, video_page would be $f0: 1111 0000 in bits.
; Let's set the screen to x,y: 45,27  --->  xpos:2D, ypos:1B
;       xpos: __101101		Shift left twice to prepare for rolling right.
;   new xpos:   101101__	The blanks just represent zero bits.

;       ypos: 00011011		Use lsr to avoid carrying bits into ypos.
; ror'd ypos: 00001101 -> 1 into the Carry flag.				

; Since we now have xpos prepared to accept carry bits from ypos, we do that.
;       xpos: 1011 0100
;     C: 1 -> ror'd-xpos -> C just gets the insignificant zero bits from ror.
;     result: 1101 1010  with  C:0

; Then we get another bit from ypos put into Carry.
;         ypos: 0000 1101
;   lsr'd ypos: 0000 0110 -> 1 into C
;    partial adrH:  ^

; Now that we've shifted it twice, the y bits that make up adrH are in place.
; So, if we want to finish it off, we can just slap the page bits over it.
;      video_page: 1111 0000
;            adrH: 0000 0110  as from the ypos shifted-right twice
;     OR-combined: 1111 0110
; adrH is now complete, and Carry still has 1 from the lsr operation previously.

; Rolling the carry bit into xpos a second time completes adrL.
;               xpos: 1101 1010
;             C: 1 -> ror'd-xpos -> C, which becomes 0
;               adrL: 1110 1101

;      --------------------------------
;     |   End of Lengthy Explanation   |  	( Implementation Follows )
;      --------------------------------

screenAddressToXYpos:
    lda adrH
    and #$0f
    sta ypos
    lda adrL
    asl
    rol ypos
    asl
    rol ypos
    lda adrL
    and #$3f
    sta xpos
rts

XYposToScreenAddress:
    lda ypos
    sta adrH
    lda xpos
    asl
    asl
    lsr adrH
    ror
    lsr adrH
    ror
    sta adrL
    lda video_page
    ora adrH
    sta adrH
rts


updateXYdisplay:

rts
