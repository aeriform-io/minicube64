	include "examples/64cube.inc"

ENUM $2
clock rBYTE 1 
frame rBYTE 1
page	rBYTE 1
sample	dsw 1  
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

	lda #$3f
	sta COLORS
	lda #$0f 
	sta VIDEO

	lda #$80 
	sta AUDIO_REGS
	lda #$ff 
	sta AUDIO_VOLUME

	lda #$04
	sta AUDIO_CHANNEL1 
	lda #$ff 
	sta AUDIO_CHANNEL1+1
	lda #$00 
	sta AUDIO_CHANNEL1+2
	lda #$1
	sta AUDIO_CHANNEL1+3


	lda #$04
	sta AUDIO_CHANNEL2 
	lda #$3f 
	sta AUDIO_CHANNEL2+1
	lda #$00 
	sta AUDIO_CHANNEL2+2
	lda #$1
	sta AUDIO_CHANNEL2+3


	lda #$00 
	sta clock
	sta frame 


	_setw irq,VBLANK_IRQ
	jsr blitonce
	cli 
@lock:
	jmp @lock

blitonce:

	;	where we are drawing too 
	_setw $f240,blit_dst_l
	;	the color to skip drawing 
	_setb $0,blit_key
	;	width and height 
	_setb 32,blit_w
	_setb 32,blit_h
	;	stride , number of pixels to add per line 
	_setb 64,blit_stride
	;	source data points to image  
	_setw image,blit_src_l
	jsr blitter_key
	rts

irq:
	lda sample 
	sta AUDIO_CHANNEL1+2
	lda sample+1
	sta AUDIO_CHANNEL1+3
	_addwi sample,2,sample
	rti


blitter_key:
	;	x coord in 0-3f range

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


image:
	incbin "examples/data/test.raw"
	org $3f00	
clut:
	incbin "examples/data/test.pal"

	org $8000
	incbin "examples/data/82S126.1m"





