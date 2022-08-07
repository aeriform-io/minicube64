include "64cube.inc"

ENUM $0
    screen dw 1
    pointer dw 1
    tiley db 1
    tile db 1
    offset db 1
    row db 1
    savey db 1
    size db 1
    temp db 1
ENDE

    org $200
Boot:
    sei
    _setb $d,COLORS
    _setb $e,VIDEO
    _setw IRQ, VBLANK_IRQ

    jsr BuildTiles
    cli


; MAIN LOOP
Main:
    jmp Main


IRQ:
    rti


; CALCULATE AND
; DRAW EACH TILE
; FROM ATLAS AND MAP
; ONCE INTO 0xe000
BuildTiles:
    ldy #0
-
    _setb #8,size
    _setw Atlas,pointer
    _setw $e000,screen

    lda Map,y
    and #%01111111
    sta tiley
    asl
    asl
    asl
    and #%00111111
    sta tile

    tya
    asl
    asl
    asl
    and #%00111111
    sta offset

    tya
    lsr
    lsr
    lsr
    asl
    sta row

    lda pointer
    clc
    adc tile
    sta pointer

    lda tiley
    lsr
    lsr
    lsr
    asl
    sta temp

    lda pointer+1
    clc
    adc temp
    sta pointer+1

    lda screen
    clc
    adc offset
    sta screen

    lda screen+1
    clc
    adc row
    sta screen+1

    sty savey

    jsr DrawTile

    ldy savey
    iny
    cpy #64
    bne -
    rts


; DRAW TILE
DrawTile:
    ldx #0
--
    ldy #0
-
    lda (pointer),y
    sta (screen),y
    iny
    cpy size
    bne -
    _addwb pointer,#64,pointer
    _addwi screen,#64,screen
    inx
    cpx size
    bne --
    rts


; TILEMAP DATA
Map:
    hex 00 01 00 16 05 06 07 08 
    hex 02 00 03 17 08 09 09 0b 
    hex 04 04 04 19 0a 0a 0b 18 
    hex 10 11 12 12 12 10 12 10 
    hex 13 14 14 14 13 14 13 14 
    hex 15 15 15 15 15 15 15 15 
    hex 0f 05 06 07 0f 05 06 07 
    hex 1b 0c 0d 0e 1a 0c 0d 0e

; GRAPHICS BY DEADLYYUCCA
    align $d00
Palette:
    incbin "demos/tilemap/tilemap.pal"
Atlas:
    incbin "demos/tilemap/tilemap.raw"