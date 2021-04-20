 include "64cube.inc"

ENUM $0
  src_l rBYTE 1
  src_h rBYTE 1
  stride rBYTE 1
  wide rBYTE 1
  high rBYTE 1
  dst_l rBYTE 1
  dst_h rBYTE 1
  ready rBYTE 1
  page rBYTE 1
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

  lda #17
  jsr FastFill

  _setw irq, VBLANK_IRQ
  cli




Main:
  lda ready
  beq Main

  _setw image,src_l
  _setw $f34c,dst_l
  _setb 40,wide
  _setb 29,high
  jsr draw

  _setw $0f80,src_l
  _setw $fb0c,dst_l
  _setb 40,wide
  _setb 9,high
  jsr draw




UP:
  lda INPUT
  and #%00010000
  beq NoUP
  _setw $0829,src_l
  _setw $f35b,dst_l
  _setb 9,wide
  _setb 12,high
  jsr draw
NoUP:

DN:
  lda INPUT
  and #%00100000
  beq NoDN
  _setw $0832,src_l
  _setw $f79b,dst_l
  _setb 9,wide
  _setb 12,high
  jsr draw
NoDN:

LT:
  lda INPUT
  and #%01000000
  beq NoLT
  _setw $0b32,src_l
  _setw $f5d1,dst_l
  _setb 12,wide
  _setb 9,high
  jsr draw
NoLT:

RT:
  lda INPUT
  and #%10000000
  beq NoRT
  _setw $0d72,src_l
  _setw $f5e2,dst_l
  _setb 12,wide
  _setb 9,high
  jsr draw
NoRT:

A:
  lda INPUT
  and #%00000001
  beq NoA
    _setw $0b29,src_l
    _setw $fb0c,dst_l
    _setb 9,wide
    _setb 9,high
    jsr draw
NoA:

B:
  lda INPUT
  and #%00000010
  beq NoB
  _setw $0d69,src_l
  _setw $fb16,dst_l
  _setb 9,wide
  _setb 9,high
  jsr draw
NoB:

C:
  lda INPUT
  and #%00000100
  beq NoC
  _setw $0fa9,src_l
  _setw $fb20,dst_l
  _setb 9,wide
  _setb 9,high
  jsr draw
NoC:

S:
  lda INPUT
  and #%00001000
  beq NoS
  _setw $0fb2,src_l
  _setw $fb6a,dst_l
  _setb 9,wide
  _setb 9,high
  jsr draw
NoS:

  lda #0
  sta ready
  jmp Main




; IRQ
irq:
  lda #1
  sta ready
  rti




draw:
  ldx #$00
@yloop:
  ldy #$00
@xloop:
  lda (src_l),y
  sta (dst_l),y
  iny
  cpy wide
  bne @xloop
  _addwb src_l,#64,src_l
  _addwi dst_l,64,dst_l
  inx
  cpx high
  bne @yloop
  rts




FastFill:
  ldx #0
Loop:
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
  bne Loop
  rts




  org $0500
  incbin "demos/input/pad_one.pal"
  image:
  incbin "demos/input/pad_one.raw"
