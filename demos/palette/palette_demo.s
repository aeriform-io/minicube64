include "64cube.inc"

  org $200
Boot:
  sei

  lda #$f
  sta VIDEO

  lda #$5
  sta COLORS

  _setw irq, VBLANK_IRQ
  cli


Loop:
  jmp Loop


irq:
  ldx #0
  @Loop:
  txa
  and #$3f
  lsr
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
  bne @Loop
  rti


  org $0500

; Palettes can be defined in a separate file
; include "demos/palette/palettes/naji16.s"
; include "demos/palette/palettes/darkseed.s"

; Palettes can be defined in hex notation
; DAWNBRINGER
  hex 140c1c
  hex 442434
  hex 30346d
  hex 4e4a4e
  hex 854c30
  hex 346524
  hex d04648
  hex 757161
  hex 597dce
  hex d27d2c
  hex 8595a1
  hex 6daa2c
  hex d2aa99
  hex 6dc2ca
  hex dad45e
  hex deeed6

; Palettes can also be defined in byte notation
; PICO8
; byte $00,$00,$00
; byte $1D,$2B,$53
; byte $7E,$25,$53
; byte $00,$87,$51
; byte $AB,$52,$36
; byte $5F,$57,$4F
; byte $C2,$C3,$C7
; byte $FF,$F1,$E8
; byte $FF,$00,$4D
; byte $FF,$A3,$00
; byte $FF,$EC,$27
; byte $00,$E4,$36
; byte $29,$AD,$FF
; byte $83,$76,$9C
; byte $FF,$77,$A8
; byte $FF,$CC,$AA
