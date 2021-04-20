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
  ; include "demos/palette/palettes/pico8.s"
  ; include "demos/palette/palettes/naji16.s"
  ; include "demos/palette/palettes/darkseed.s"

; DAWNBRINGER
  DB $14,$0c,$1c
  DB $44,$24,$34
  DB $30,$34,$6d
  DB $4e,$4a,$4e
  DB $85,$4c,$30
  DB $34,$65,$24
  DB $d0,$46,$48
  DB $75,$71,$61
  DB $59,$7d,$ce
  DB $d2,$7d,$2c
  DB $85,$95,$a1
  DB $6d,$aa,$2c
  DB $d2,$aa,$99
  DB $6d,$c2,$ca
  DB $da,$d4,$5e
  DB $de,$ee,$d6
