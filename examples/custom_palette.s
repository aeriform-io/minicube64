	include "examples/64cube.inc"

ENUM $2
clock rBYTE 1 
frame rBYTE 1
page	rBYTE 1 
offscreen rBYTE 1
music_ptr rWORD 1
tmp 			rBYTE 1
blit_src_l rBYTE 1
blit_src_h rBYTE 1
blit_stride rBYTE 1
blit_w rBYTE 1
blit_h rBYTE 1
blit_dst_l rBYTE 1
blit_dst_h rBYTE 1
blit_key rBYTE 1

ENDE


	;	we ALWAYS boot to $200 

	org $200 
boot:
	sei
	ldx #$ff	;	set stack 
	txs

	lda #>colorram
	sta COLORS
	lda #$0f 
	sta VIDEO

	lda #$00 
	sta clock
	sta frame 

	_unpack image,$8000

	_setb $f0,offscreen
	jsr blitonce
	_setw irq,VBLANK_IRQ
	cli 
@lock:
	jmp @lock

blitonce:
	_setw $f240,blit_dst_l
	ldx #$00 
@ycolorsloop
	ldy #$00 
@colors
	txa
	sta (blit_dst_l),y

	iny
	cpy #64
	bne @colors
	sta tmp
	_addwi blit_dst_l,64,blit_dst_l
	lda tmp
	clc
	adc #$1
	inx 
	cpx #24 
	bne @ycolorsloop

	_setb $33,blit_key
	_setb 64,blit_w
	_setb 64,blit_h
	_setb 64,blit_stride
	_setw $8000,blit_src_l

	ldx #$00 
	ldy #$00 
	jsr blitter_key
	rts


irq:
	inc clock 

	lda clock
	and #$7f 
	tay 
	clc 
	lda #$00 
;	* 3
	adc sinus,y
	adc sinus,y
	adc sinus,y

	tax 
	ldy #$03
@yloop 
	lda clut,x 
	sta colorram,y 
	inx
	iny
	cpy #63*3
	bne @yloop 


	rti


blitter_key:
	;	x coord in 0-3f range
	lda #$00
	sta blit_dst_l 
	lda offscreen
	sta blit_dst_h

	ldx #$00 
@blitter_yloop:
	ldy #$00 
@blitter_xloop:
	lda (blit_src_l),y 
	cmp blit_key
	beq @noblit
	sta (blit_dst_l),y 
@noblit:
	iny 
	cpy blit_w
	bne @blitter_xloop
	_addwb blit_src_l,blit_stride,blit_src_l
	_addwi blit_dst_l,64,blit_dst_l
	inx 
	cpx blit_h 
	bne @blitter_yloop
	rts

offscreen_addr:
	byte $f0,$e0

	include "examples/dcf6.s"
sinus:	
	incbin	"examples/data/sin.bin"
image:
	incbin "examples/data/boot.c6f"
clut:
	incbin "examples/data/helmet.pal"

colorram = $3f00



