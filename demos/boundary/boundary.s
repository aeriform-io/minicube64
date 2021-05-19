include "64cube.inc"

ENUM $0
  ready       rBYTE 1
  counter     rBYTE 1
  clock       rBYTE 1
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
  colour      rBYTE 1
  xspeed      rBYTE 1
  yspeed      rBYTE 1
ENDE

  org $200
  sei
  ldx #$ff
  txs

  lda #$f
  sta VIDEO

  lda #$5
  sta COLORS

  MAXCOLOURS = 6

  lda #21
  sta xpos
  lda #26
  sta ypos

  lda #1
  sta xspeed
  sta yspeed

  lda #MAXCOLOURS
  sta colour

  _setw IRQ, VBLANK_IRQ
  cli


Main:
  lda ready
  beq Main

  jsr Clear

  _setb 23,wide
  _setb 12,high
  _setw sprite,src_l

  ldx xpos
  ldy ypos
  jsr SetPos

  jsr Draw

  lda #0
  sta ready
  jmp Main


IRQ:

  CheckX:
    ldx xpos
    cpx #64-23
    bne +
    jsr SetColour
    lda #$ff
    sta xspeed
  +
    cpx #0
    bne ++
    jsr SetColour
    lda #1
    sta xspeed
  ++


  CheckY
    ldx ypos
    cpx #64-12
    bne +
    jsr SetColour
    lda #$ff
    sta yspeed
  +
    cpx #0
    bne ++
    jsr SetColour
    lda #1
    sta yspeed
  ++


  Timer
    lda counter
    cmp #2
    bne +

    clc
    lda xpos
    adc xspeed
    sta xpos

    clc
    lda ypos
    adc yspeed
    sta ypos

    lda #0
    sta counter
    +
    inc counter


    lda #1
    sta ready

  rti


Draw:
  ldx #0
-
  ldy #0
--
  lda (src_l),y
  cmp mask
  beq +
  lda colour
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
  lda #0
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
  bne -
  rts


SetColour:
  lda clock
  cmp #2
  bne +

  lda colour
  cmp #MAXCOLOURS
  bne ++

  lda #0
  sta colour
  ++
  inc colour

  lda #0
  sta clock
  +
  inc clock
  rts


SetPos:
  lda #0
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







  org $0500

  hex 000000 ff0000 ff00ff 0000ff 00ffff 00ff00 ffffff
sprite:
  incbin "tool/dvd.raw"
