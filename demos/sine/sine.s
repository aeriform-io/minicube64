; SINE DEMO BY VISY @notyourusualcup

include "64cube.inc"

ENUM $0
  frame rBYTE 1
  pnt rWORD 1
  yc rBYTE 1
  lines rBYTE 1
  line_pad rBYTE 1
  line_end rBYTE 1

ENDE

  org $200
  sei
  ldx #$ff
  txs

  lda #$0f ; video to $f000
  sta VIDEO

  _setw irq, VBLANK_IRQ
  cli

loop:
  jsr filler

  jmp loop

filler:

  lda #$f0
  sta pnt+1

  lda #0
  sta yc
  sta lines
yloop:

  lda frame
  clc
  sbc lines
  tax
  lda sintab,x
  clc
  sbc frame
  lsr
  lsr
  lsr
  sta line_pad

  lda #65
  clc
  sbc line_pad
  sta line_end

  lda yc
  sta pnt+0

  ldy line_pad
  lda lines
  adc frame
  sbc line_pad
  lsr
  lsr
xloop:
  sta (pnt),y
  iny
  cpy line_end
  bne xloop

  lda yc
  clc
  adc #64
  sta yc

  lda pnt+1
  adc #0
  sta pnt+1

  inc lines
  lda lines
  cmp #64

  bne yloop

  rts

irq:
  inc frame
  rti

sintab:
byte $7f,$82,$85,$88,$8c,$8f,$92,$95,$98,$9b,$9e,$a1,$a4,$a7,$aa,$ad,$b0,$b3,$b6,$b9,$bb,$be,$c1,$c3,$c6,$c9,$cb,$ce,$d0,$d3,$d5,$d7,$d9,$dc,$de,$e0,$e2,$e4,$e6,$e8,$e9,$eb,$ed,$ee,$f0,$f1,$f2,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fc,$fd,$fd,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fd,$fd,$fc,$fc,$fb,$fa,$fa,$f9,$f8,$f7,$f6,$f4,$f3,$f2,$f0,$ef,$ed,$ec,$ea,$e8,$e7,$e5,$e3,$e1,$df,$dd,$db,$d8,$d6,$d4,$d1,$cf,$cc,$ca,$c7,$c5,$c2,$bf,$bd,$ba,$b7,$b4,$b1,$af,$ac,$a9,$a6,$a3,$a0,$9d,$9a,$96,$93,$90,$8d,$8a,$87,$84,$81,$7d,$7a,$77,$74,$71,$6e,$6b,$68,$64,$61,$5e,$5b,$58,$55,$52,$4f,$4d,$4a,$47,$44,$41,$3f,$3c,$39,$37,$34,$32,$2f,$2d,$2a,$28,$26,$23,$21,$1f,$1d,$1b,$19,$17,$16,$14,$12,$11,$0f,$0e,$0c,$0b,$0a,$08,$07,$06,$05,$04,$04,$03,$02,$02,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0c,$0d,$0e,$10,$11,$13,$15,$16,$18,$1a,$1c,$1e,$20,$22,$25,$27,$29,$2b,$2e,$30,$33,$35,$38,$3b,$3d,$40,$43,$45,$48,$4b,$4e,$51,$54,$57,$5a,$5d,$60,$63,$66,$69,$6c,$6f,$72,$76,$79,$7c,$7f
