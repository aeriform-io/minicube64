include "64cube.inc"

ENUM $0
  counter rBYTE 1
  last rBYTE 1
  enable  rBYTE 1
  held  rBYTE 1
ENDE

  org $200
  sei
  ldx #$ff
  txs

  lda #$20
  sta COLORS

  _setw IRQ, VBLANK_IRQ
  cli

Infinite:

  lda enable
  sta VIDEO

  jsr KonamiCode

  lda counter

  ldx #0
BasicFill:
  sta $0300,x
  sta $0500,x
  sta $0700,x
  sta $0900,x
  sta $0b00,x
  sta $0d00,x
  sta $0f00,x
  dex
  bne BasicFill

	jmp Infinite

KonamiCode:
  ldy counter
  lda INPUT
  and #%11110011
  beq done
  cmp code,y
  beq continue
  lda #0
  sta counter
  rts
continue:
  iny
  sty counter

  lda #0
  sta INPUT

  cpy #$0a
  bcc done
  lda #$01
  sta enable
done:
  sty counter

  rts
code:
  byte $10,$10,$20,$20,$40,$80,$40,$80,$01,$02

IRQ:
  rti

  org $1000
  incbin "demos/konamicode/konami.raw"

  org $2000
  hex 003ffb 0045fc 899bff ffffff
  palette:
  hex ff0000 00ff00 0000ff ff00ff ffff00 00ffff
