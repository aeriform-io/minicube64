        apd_bitbuffer = $f5
        apd_src       = $f6
				apd_src_l 		= apd_src+1
        apd_length    = $f8
				apd_length_l 	= apd_length+1
        apd_offset    = $fa
				apd_offset_l 	= apd_offset+1
        apd_source    = $fc
				apd_source_l 	= apd_source+1
        apd_dest      = $fe
				apd_dest_l 		= apd_dest+1

MACRO incsrc
        inc     apd_src
        bne     incsr1
        inc     apd_src+1
incsr1:
ENDM

MACRO	getbyte
        lda     (apd_src),y
        incsrc
ENDM

MACRO putbyte
        sta     (apd_dest),y
        inc     apd_dest
        bne     putbyt
        inc     apd_dest+1
putbyt:
ENDM

MACRO getbit
	asl     apd_bitbuffer
	bne     getbi1
	tax
	getbyte
	rol
	sta     apd_bitbuffer
	txa
getbi1
ENDM
MACRO getbitd
        asl     apd_bitbuffer
        bne     getbi2
        getbyte
        rol
        sta     apd_bitbuffer
getbi2 
ENDM


exitdz: rts
dc64f:  lda     #$80
        sta     apd_bitbuffer
        ldy     #0
        sty     apd_length+1
copyby: 
	getbyte
        putbyte
mainlo: getbitd
        bcc     copyby
        sty     apd_offset+1
        getbitd
        lda     #1
        bcs     contie
lenval: getbit
        rol
        rol     apd_length+1
        getbit
        bcc     lenval
contie: adc     #0
        sta     apd_length
        beq     exitdz
        lda     (apd_src), y
        bpl     toffen
        incsrc
        getbit
        rol     apd_offset+1
        getbit
        rol     apd_offset+1
        getbit
        rol     apd_offset+1
        getbit
        bcc     offend
        inc     apd_offset+1
        sbc     #$80
        jmp     offend
toffen: incsrc
offend: sec
        sbc     apd_dest
        eor     #%11111111
        sta     apd_source
        lda     apd_offset+1
        sbc     apd_dest+1
        eor     #%11111111
        sta     apd_source+1
        lda     apd_length+1
        beq     skip
loop1:  lda     (apd_source), y
        sta     (apd_dest), y
        iny
        bne     loop1
        inc     apd_source+1
        inc     apd_dest+1
        dec     apd_length+1
        bne     loop1
skip:   ldx     apd_length
        beq     lopend
loop2:  lda     (apd_source), y
        sta     (apd_dest), y
        iny
        dex
        bne     loop2
        tya
        ldy     #0
        adc     apd_dest
        sta     apd_dest
        bcc     lopend
        inc     apd_dest+1
lopend: jmp     mainlo

