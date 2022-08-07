include "64cube.inc"

ENUM $0
    screen dw 1
    pointer dw 1
    counter db 1
    tiley db 1
    tile db 1
    offset db 1
    row db 1
    savey db 1
    size db 1
    temp db 1
    flicker db 1
    ready db 1
ENDE

    org $200
Boot:
    sei
    _setb $d,COLORS
    _setb $f,VIDEO
    _setw IRQ, VBLANK_IRQ

    SIGN EQU #$d12
    jsr BuildTiles
    cli


; MAIN LOOP
Main:
    lda ready
    beq Main

    ; COPY TILES TO SCREEN
        _setb #64,size
        _setw $e000,pointer
        _setw $f000,screen
        jsr DrawTile

    ; DRAW CAR
        _setw $1800,pointer
        _setw $f9c0,screen
        jsr DrawCar

        jsr Move ;MOVE CAR
        jsr Flicker ;FLICKER SIGN

    lda #0
    sta ready
    jmp Main


IRQ:
    jsr Update

    lda #1
    sta ready
    rti


Update:
    lda counter
    cmp #10
    bne ++

    lda flicker
    cmp #32
    bcc +
    lda #0
    sta flicker
+
    inc flicker

    lda #0
    sta counter
++
    inc counter
    rts


Flicker:
    ldy flicker
    lda Pattern,y
    beq +

    lda #$ff
    sta SIGN
    sta SIGN+2
    jmp ++
+
    lda #0
    sta SIGN
    sta SIGN+2
++
    rts


Move:
    _setw $1801,pointer
    _setw $1800,screen
    ldx #0
--
    ldy #0
-
    lda (pointer),y
    sta (screen),y
    iny
    cpy #63
    bne -
    _addwb pointer,#64,pointer
    _addwi screen,#64,screen
    inx
    cpx #8
    bne --
    _setw $1800,pointer
    _setw $183f,screen
    ldy #0
-
    lda (pointer),y
    sta (screen),y
    _addwi pointer,#63,pointer
    _addwi screen,#63,screen
    iny
    cpy #8
    bne -
+
    rts


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


DrawCar:
    ldx #0
--
    ldy #0
-
    lda (pointer),y
    cmp #3
    beq +
    sta (screen),y
+
    iny
    cpy #64
    bne -
    _addwb pointer,#64,pointer
    _addwi screen,64,screen
    inx
    cpx #8
    bne --
    rts

; ; FLICKER PATTERN FOR SIGN
Pattern:
    hex ff 00 ff ff 00 ff 00 00
    hex ff 00 ff 00 ff 00 00 ff
    hex ff ff 00 ff 00 ff 00 ff
    hex ff ff ff ff ff ff 00 ff

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

    align $1000
Atlas:
    incbin "demos/tilemap/tilemap.raw"