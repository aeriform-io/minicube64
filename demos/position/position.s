include "64cube.inc"

ENUM $0
  ready       rBYTE 1
  src_l       rBYTE 1
  src_h       rBYTE 1
  wide        rBYTE 1
  high        rBYTE 1
  mask        rBYTE 1
  xpos        rBYTE 1
  ypos        rBYTE 1
  temp        rBYTE 1
  dst_l       rBYTE 1
  dst_h       rBYTE 1
ENDE

  org $200
Boot:
  sei
  ldx #$ff
  txs

  lda #$f
  sta VIDEO

  lda #$5
  sta COLORS

  lda #28
  sta xpos
  lda #14
  sta ypos

  _setw IRQ, VBLANK_IRQ
  cli

Main:
  lda ready
  beq Main

  jsr Clear

  _setb 0,mask
  _setb 8,wide
  _setb 7,high
  _setw sprite,src_l

  ldx xpos
  ldy ypos
  jsr SetPos

  jsr Draw

  lda #0
  sta ready
  jmp Main

IRQ:
  UP:
    lda INPUT
    and #%00010000
    beq NoUP
    lda ypos
    beq NoUP
    dec ypos
  NoUP:

  DN:
    lda INPUT
    and #%00100000
    beq NoDN
    lda ypos
    cmp #28
    beq NoDN
    inc ypos
  NoDN:

  LT:
    lda INPUT
    and #%01000000
    beq NoLT
    lda xpos
    beq NoRT
    dec xpos
  NoLT:

  RT:
    lda INPUT
    and #%10000000
    beq NoRT
    lda xpos
    cmp #57
    beq NoRT
    inc xpos
  NoRT:

  Other:
    lda INPUT
    and #%00001111
    beq NoOther
    lda #28
    sta xpos
    lda #14
    sta ypos
  NoOther:

  lda #1
  sta ready
  rti

SetPos:
	lda #$00
	sta temp
	clc

	tya
	ror
	ror temp
	ror
	ror temp

	sta dst_h
	lda temp
	sta dst_l

	lda dst_h

	clc
	adc dst_h
	adc #$F0
	sta dst_h

	clc
	lda temp
	adc dst_l
	sta dst_l

	lda dst_h
	adc #0
	sta dst_h

	clc
	txa
	adc dst_l
	sta dst_l

	rts

Draw:
    ldx #$00
  @yloop:
    ldy #$00

  @xloop:
    lda (src_l),y
    cmp mask
    beq @skip
    sta (dst_l),y

  @skip:
    iny
    cpy wide
    bne @xloop
    _addwb src_l,wide,src_l
    _addwi dst_l,64,dst_l
    inx
    cpx high
    bne @yloop
  rts

Clear:
    ldx #0
  clear:
    lsr
    sta $f000,x
    sta $f100,x
    sta $f200,x
    sta $f300,x
    sta $f400,x
    sta $f500,x
    sta $f600,x
    sta $f700,x
    sta $f800,x
    sta $f900,x
    sta $fa00,x
    sta $fb00,x
    sta $fc00,x
    sta $fd00,x
    sta $fe00,x
    sta $ff00,x
    dex
    bne clear
  rts


  org $0500

palette:
  hex 0052cc
  hex ffffff

sprite:
  DB $01,$00,$01,$00,$00,$00,$00,$00
  DB $01,$01,$01,$00,$00,$00,$01,$00
  DB $01,$01,$01,$00,$00,$00,$01,$00
  DB $01,$01,$01,$00,$00,$01,$00,$00
  DB $00,$01,$01,$01,$01,$00,$00,$00
  DB $00,$01,$01,$01,$01,$00,$00,$00
  DB $00,$01,$00,$00,$01,$00,$00,$00
