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
colorram = $3f00

ENDE

	;	we ALWAYS boot to $200 

	org $200 
	sei
	ldx #$ff	;	set stack 
	txs
	inx 
	stx APU_DMC_FREQ


	lda #>song
	sta AUDIO

	ldx #<after_the_rain_music_data	;initialize using the first song data, as it contains the DPCM sound effect
	ldy #>after_the_rain_music_data
;	ldx #<danger_streets_music_data	;initialize using the first song data, as it contains the DPCM sound effect
;	ldy #>danger_streets_music_data
;	ldx #<strike_the_earth_plains_of_passage_music_data
;	ldy #>strike_the_earth_plains_of_passage_music_data
	lda #$0
	jsr FamiToneInit		;init FamiTone

	lda #0
	jsr FamiToneMusicPlay

	lda #>colorram
	sta COLORS
	lda #$0f 
	sta VIDEO


	lda #$00 
	sta clock
	sta frame 

	_setw image,apd_src 
	_addwi apd_src,0,apd_src
	_setw $8000,apd_dest
	jsr dc64f
	

	_setb $f0,offscreen

	_setw irq,VBLANK_IRQ


	jsr blitonce

	cli 
lock:
	jmp lock

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

	ldy clock
	clc 
	lda #$00 
;	* 3
	adc sinus,y
	adc sinus,y
	adc sinus,y
	tax
	ldy #$03
@yloop 
	inx
	txa
	and #$7f
	tax 

	lda clut,x 
	sta colorram,y 
	iny
	cpy #63*3
	bne @yloop 

	jsr FamiToneUpdate		;update sound

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


	FT_BASE_ADR		= $Df00	;page in the RAM used for FT2 variables, should be $xx00
	FT_TEMP			= $f0	;3 bytes in zeropage used by the library as a scratchpad
	FT_DPCM_OFF		= $00	;$c000..$ffc0, 64-byte steps
	FT_SFX_STREAMS	= 4		;number of sound effects played at once, 1..4

	FT_DPCM_ENABLE			;undefine to exclude all DMC code
	FT_NTSC_SUPPORT			;undefine to exclude PAL support


	include "examples/dcf6.s"

	include "examples/famitone2/_asm6.asm"
	include "examples/famitone2/after_the_rain.asm"

;	include "asmdata/danger_streets.asm"
;	include "asmdata/shovel_knight_ost_strike_the_earth_plains_of_passage.asm"

sinus:	
	incbin	"examples/data/sin.bin"
image:
	incbin "examples/data/boot.c6f"
	align 256
clut:
	incbin "examples/data/helmet.pal"

	align 256
song:
	incbin "examples/famitone2/after_the_rain.dmc"

;E:/Projects/tinyfb2/distro/examples/famitone2/after_the_rain.dmc
;E:/Projects/tinyfb2/distro/examples/famitone2/after_the_rain.c6f