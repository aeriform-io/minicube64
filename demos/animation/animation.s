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
  dst_l       rBYTE 1
  dst_h       rBYTE 1
  temp        rBYTE 1
  frames      rBYTE 1
  fcount      rBYTE 1
  counter     rBYTE 1
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

  lda #64-36
  sta xpos
  sta ypos

  _setw IRQ, VBLANK_IRQ
  cli


Main:
  lda ready
  beq Main

  jsr Clear

  _setb 0,mask
  _setb 6,wide
  _setb 10,high

  ldx fcount

  lda SpriteLoPtr,x
  sta src_l
  lda SpriteHiPtr,x
  sta src_l+1

  ldx xpos
  ldy ypos
  jsr SetPos

  jsr Draw

  lda #0
  sta ready
  jmp Main

IRQ:
  lda #1
  sta ready


Timer:
  lda counter
  cmp #6
  bne +
  inc fcount

  lda xpos
  cmp #64-6
  bne ++
  inc xpos
  lda #0
  sta xpos
++
  inc xpos

  lda fcount
  cmp #8
  bne +++
  lda #0
  sta fcount
+++
  lda #0
  sta counter
+
  inc counter

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
  -
    ldy #$00
  --
    lda (src_l),y
    cmp mask
    beq +
    sta (dst_l),y
  +
    iny
    cpy wide
    bne --
    _addwb src_l,wide,src_l
    _addwi dst_l,64,dst_l
    inx
    cpx high
    bne -
  rts


Clear:
    ldx #0
  -
    lsr
    sta $f700,x
    sta $f800,x
    sta $f900,x
    dex
    bne -
  rts


  org $0500

palette:
  hex 000000 ffebdf 00FF00 0000FF

  SpriteLoPtr:
  db <(frame1)
  db <(frame2)
  db <(frame3)
  db <(frame4)
  db <(frame5)
  db <(frame6)
  db <(frame7)
  db <(frame8)

  SpriteHiPtr:
  db >(frame1)
  db >(frame2)
  db >(frame3)
  db >(frame4)
  db >(frame5)
  db >(frame6)
  db >(frame7)
  db >(frame8)

frame1:
  db $00,$00,$00,$00,$00,$00
  db $00,$02,$02,$02,$02,$00
  db $00,$02,$02,$01,$00,$00
  db $00,$00,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$03,$03,$00,$00
  db $00,$01,$03,$03,$00,$00
  db $00,$00,$01,$01,$00,$00
frame2:
  db $00,$00,$02,$00,$02,$00
  db $00,$02,$02,$02,$00,$00
  db $00,$02,$02,$01,$00,$00
  db $00,$00,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$01,$03,$03,$00,$00
  db $00,$01,$03,$03,$00,$01
  db $00,$00,$03,$03,$00,$01
  db $00,$03,$03,$00,$01,$00
  db $00,$01,$01,$00,$00,$00
frame3;
  db $00,$00,$00,$00,$00,$00
  db $00,$02,$00,$02,$00,$00
  db $00,$02,$02,$02,$00,$00
  db $00,$00,$02,$01,$00,$00
  db $00,$00,$01,$01,$01,$00
  db $00,$01,$01,$03,$00,$00
  db $00,$01,$03,$03,$00,$00
  db $01,$01,$03,$03,$03,$00
  db $00,$03,$03,$03,$03,$00
  db $01,$01,$00,$00,$01,$01
frame4:
  db $00,$00,$00,$00,$00,$00
  db $00,$00,$02,$02,$00,$00
  db $00,$02,$02,$01,$02,$00
  db $00,$02,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$01,$03,$03,$00,$00
  db $00,$00,$03,$03,$00,$00
  db $01,$03,$03,$03,$03,$00
  db $01,$00,$00,$01,$01,$00

frame5:
  db $00,$00,$00,$00,$00,$00
  db $00,$02,$02,$02,$02,$00
  db $00,$02,$02,$01,$00,$00
  db $00,$02,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$03,$01,$00,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$03,$03,$00,$00
  db $00,$01,$03,$03,$00,$00
  db $00,$00,$01,$01,$00,$00
frame6:
  db $00,$00,$02,$00,$02,$00
  db $00,$02,$02,$02,$00,$00
  db $00,$02,$02,$01,$00,$00
  db $00,$00,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$03,$01,$00,$00
  db $00,$00,$03,$01,$00,$01
  db $00,$00,$03,$03,$00,$01
  db $00,$03,$03,$00,$01,$00
  db $00,$01,$01,$00,$00,$00
frame7:
  db $00,$00,$00,$00,$00,$00
  db $00,$02,$00,$02,$00,$00
  db $00,$02,$02,$02,$00,$00
  db $00,$00,$02,$01,$00,$00
  db $00,$00,$01,$01,$01,$00
  db $00,$00,$03,$01,$00,$00
  db $00,$00,$03,$01,$00,$00
  db $00,$00,$03,$03,$01,$00
  db $00,$03,$03,$03,$03,$00
  db $01,$01,$00,$00,$01,$01
frame8:
  db $00,$00,$00,$00,$00,$00
  db $00,$00,$02,$02,$00,$00
  db $00,$02,$02,$01,$02,$00
  db $00,$02,$01,$01,$01,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$01,$03,$00,$00
  db $00,$00,$03,$01,$00,$00
  db $00,$00,$03,$03,$00,$00
  db $01,$03,$03,$03,$03,$00
  db $01,$00,$00,$01,$01,$00
