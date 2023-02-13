
	org $BFF0
	db "NES",$1a
	db $1
	db $1
	db %00000000
	db %00000000
	db 0
	db 0,0,0,0,0,0,0


curs_x equ $40
curs_y equ curs_x+1

vblanked equ $7f


nmihandler:
	pha
	php
		inc vblanked
	plp
	pla
	
	ldx #$00 	; Set SPR-RAM address to 0
	stx $2003
spriteloop:
	lda hello,x
	sta $2004
	inx
	cpx #$14
	bne spriteloop
	rti


irqhandler:
	rti


startgame:
	sei
	cld

	ldx #$ff
	txs
	
	
	ldx #$3F
	stx $2006
	ldx #$00
	stx $2006
copypalloop:
	lda initial_palette,x
	sta $2007
	inx
	cpx #32
	bcc copypalloop
	

	lda #%00011110
	sta $2001
	lda #$80
	sta $2000


forever:
	jmp forever



initial_palette:
	db $2A,$18,$28,$38,$0F,$06,$16,$26
	db $0F,$08,$19,$2A,$0F,$02,$12,$2A
	db $22,$08,$16,$37,$0F,$06,$16,$26
	db $0F,$0A,$1A,$2A,$0F,$02,$12,$22


hello:
	;db $00, $00, $00, $00 	; Why do I need these here?
	;db $00, $00, $00, $00
	db $6c, $FD, $00, $85
	db $6c, $FD, $00, $85
	db $6c, $FE, $00, $8d
	db $6c, $FD, $00, $85
	db $6c, $FE, $00, $8d


	org $FFFA
	dw nmihandler
	dw startgame
	dw irqhandler

CHRROM_START:

	incbin "mario.chr"

CHRROM_END:

; Pad chr-rom to 8k(to make valid file)
	ds 8192-(CHRROM_END-CHRROM_START)

