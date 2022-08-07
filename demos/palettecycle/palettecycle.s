  include "64cube.inc"

  ENUM $0
    pointer dw 1
    screen  dw 1
  ENDE

    org $200
  Boot:
    sei

    _setb #$f,VIDEO
    _setb #$5,COLORS
    _setw IRQ, VBLANK_IRQ
  cli

  ; FILL SCREEN ONCE
  ; WITH COLOURS
  ldx #0
-
  txa
  sta $f000,x
  and #$3f
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

Main:
  jmp Main

IRQ:
  ; ONCE PER FRAME
  ; COPY FIRST COLOUR (3 BYTES)
  ; TO TEMP SPACE 0x05C0
  _setw $500,pointer
  _setw $5c0,screen
  ldy #0
-
  lda (pointer),y
  sta (screen),y
  iny
  cpy #3
  bne -

  ; SHIFT PALETTE DATA LEFT
  ; BY 3 BYTES
  _setw $503,pointer
  _setw $500,screen
  ldy #0
-
  lda (pointer),y
  sta (screen),y
  iny
  cpy #192
  bne -
  rti

  ; 6-BIT RGB PALETTE FROM LOSPEC.COM
  align $500
  hex 000000 000055 0000aa 0000ff 550000 550055 5500aa 5500ff aa0000 aa0055 aa00aa aa00ff ff0000 ff0055 ff00aa ff00ff 005500 005555 0055aa 0055ff 555500 555555 5555aa 5555ff aa5500 aa5555 aa55aa aa55ff ff5500 ff5555 ff55aa ff55ff 00aa00 00aa55 00aaaa 00aaff 55aa00 55aa55 55aaaa 55aaff aaaa00 aaaa55 aaaaaa aaaaff ffaa00 ffaa55 ffaaaa ffaaff 00ff00 00ff55 00ffaa 00ffff 55ff00 55ff55 55ffaa 55ffff aaff00 aaff55 aaffaa aaffff ffff00 ffff55 ffffaa ffffff