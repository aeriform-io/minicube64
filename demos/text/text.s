include "64cube.inc"

ENUM $0
    pointer dw 1
    screen dw 1
    string dw 1
    tiley db 1
    tile db 1
    offset db 1
    row db 1
    keepy db 1
    ink db 1
    ba db 0
    line db 1
    press db 1
    temp db 1
    ready db 1
ENDE
    org $200
    sei
    ldx #$ff
    txs

    _setb $0e,COLORS
    _setb $f,VIDEO
    _setw IRQ, VBLANK_IRQ

    ; SET UP ALIASES
    SPOOL EQU #$1540
    SCREEN EQU #$f602
    PROMPT EQU #$ff7d
    MAXCHARS EQU #45
    MAXLINES EQU #13
    cli

    ; SET FIRST LINE
    _setb #1,ink
    jsr Print


Main:
    lda ready
    beq Main

    ; COPY TEXT BUFFER TO SCREEN
        _setw SPOOL,pointer
        _setw SCREEN,screen
        jsr DIALOG

    ; DRAW PROMPT ON BUTTON DOWN
        lda ba
        and #$0e
        sta PROMPT-129
        sta PROMPT-2
        sta PROMPT

    _setb 0,ready
jmp Main


IRQ:
    ; CHECK FOR INPUT
    lda INPUT
    lsr
    ror ba

    bit ba
    bmi +
    bvc +

    jsr Next
    +

    _setb 1,ready
rti


Next:
    ; ADVANCE TO NEXT LINE
    lda line
    cmp #12
    bne +
    _setb $0f,COLORS
    +
    lda line
    cmp MAXLINES
    beq +
    inc line
    inc ink
    jsr Print
    +
rts


Print:
    ; PRINT LETTERS FROM STRING
    ; TO SPOOL
    ldx #0
-
    lda #0
    sta $1500,x
    sta $1600,x
    sta $1700,x
    sta $1800,x
    dex
    bne -

    ldy #0
-
    _setw Font,pointer
    _setw SPOOL,screen

    ldx line

    lda StringLo,x
    sta string
    lda StringHi,x
    sta string+1

    lda (string),y
    cmp #$23
    beq +

    sec
    sbc #$20
    sta tiley
    asl
    asl
    sta tile

    tya
    asl
    asl
    sta offset

    tya
    lsr
    lsr
    lsr
    lsr
    sta row

    lda pointer
    clc
    adc tile
    sta pointer

    lda tiley
    lsr
    lsr
    lsr
    lsr
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

    sty keepy

    jsr Char

    ldy keepy
    iny
    cpy MAXCHARS
    bne -
+
rts


Char:
    ; GET CHARACTER
    ldx #0
--
    ldy #0
-
    lda (pointer),y
    cmp #0
    beq +
    lda ink
    sta (screen),y
+
    iny
    cpy #4
    bne -
    _addwb pointer,#64,pointer
    _addwi screen,#64,screen
    inx
    cpx #4
    bne --
rts


DIALOG:
    ; COPY TEXT BUFFER TO SCREEN
    ldx #0
    --
    ldy #0
    -
    lda (pointer),y
    sta (screen),y
    iny
    cpy #62
    bne -
    _addwb pointer,#64,pointer
    _addwi screen,#64,screen
    inx
    cpx #17
    bne --
rts


StringLo:
    db <(l01)
    db <(l02)
    db <(l03)
    db <(l04)
    db <(l05)
    db <(l06)
    db <(l07)
    db <(l08)
    db <(l09)
    db <(l10)
    db <(l11)
    db <(l12)
    db <(l13)
    db <(l14)
StringHi:
    db >(l01)
    db >(l02)
    db >(l03)
    db >(l04)
    db >(l05)
    db >(l06)
    db >(l07)
    db >(l08)
    db >(l09)
    db >(l10)
    db >(l11)
    db >(l12)
    db >(l13)
    db >(l14)


l01: db "DAD WAS SUCH A  DRAG.$#"
l02: db "EVERY DAY HE'D  EAT THE SAME    KIND OF FOOD.#"
l03: db "DRESS THE SAME.#"
l04: db "SIT IN FRONT OF THE SAME KIND   OF GAMES...#"
l05: db "YEAH, HE WAS    JUST THAT KIND  OF GUY.#"
l06: db "BUT THEN ONE    DAY HE GOES AND KILLS US ALL!#"
l07: db "HE COULDN'T     EVEN BE         ORIGINAL...#"
l08: db "ABOUT THE WAY   HE DID IT.#"
l09: db "I'M NOT         COMPLAINING...#"
l10: db "I WAS DYING OF  BOREDOM ANYWAY.#"
l11: db "BUT GUESS WHAT?#"
l12: db "I WILL BE       COMING BACK.#"
l13: db "AND I'M         BRINGING MY NEW TOYS WITH ME.#"
l14: db "    204863#"


align $0e00
Palette:
    hex 000000
    hex 444444
    hex 555555
    hex 666666
    hex 777777
    hex 888888
    hex 999999
    hex aaaaaa
    hex bbbbbb
    hex cccccc
    hex dddddd
    hex eeeeee
    hex ffffff
    hex ffffff
    hex ffffff

align $0f00
    hex ffffff
    hex 000000

align $1000
Font:
    incbin "demos/text/font.raw"