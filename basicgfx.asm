	; Basic Graphics Program
	; by Thomas Wesley Scott, 2023

	; Code starts at $C000.
	; org jump to $BFFO for header info


	org $BFF0
	db "NES",$1a
	db $1
	db $1
	db %00000000
	db %00000000
	db 0
	db 0,0,0,0,0,0,0


nmihandler:
	pha
	php

	lda #$02
	sta $4014

	plp
	pla

	rti
	

irqhandler:
	rti

startgame:
	sei				; Disable interrupts
	cld				; Clear decimal mode

	ldx #$ff	
	txs				; Set-up stack
	inx				; x is now 0
	stx $2000		; Disable/reset graphic options 
	stx $2001		; Make sure screen is off
	stx $4015		; Disable sound

	stx $4010		; Disable DMC (sound samples)
	lda #$40
	sta $4017		; Disable sound IRQ
	lda #0	
waitvblank:
	bit $2002		; check PPU Status to see if
	bpl waitvblank	; vblank has occurred.
	lda #0
clearmemory:		; Clear all memory info
	sta $0000,x
	sta $0100,x
	sta $0300,x
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	lda #$FF
	sta $0200,x		; Load $FF into $0200 to 
	lda #$00		; hide sprites 
	inx				; x goes to 1, 2... 255
	cpx #$00		; Loop ends after 256 times,
	bne clearmemory ; clearing all memory


waitvblank2:
	bit $2002		; Check PPU Status one more time
	bpl waitvblank2	; before we start loading in graphics	
	lda $2002
	ldx #$3F
	stx $2006
	ldx #$00
	stx $2006
copypalloop:
	lda initial_palette,x
	sta $2007
	inx
	cpx #$20
	bcc copypalloop

		
	ldx #$02 		; Store sprite info 
	sta $4014		; into OAM DMA


	; Loop to load in sprite tile info
	ldx #0 			; Set loop counter to 0
spriteload:
	lda sprites,x	; Loads one of four values into $0200,x:
	sta $0200,x 	; x-value, tile #, flip options, y-value
	inx
	cpx #$20 		; Loop 32 times (8 tiles with 4 attributes each)
	bne spriteload


; Setup background


	ldy #$FF 	; Setup outer loop counter
	lda $2002	; Reset address high-low latch for $2006
	lda #$20 	; Load high byte of $2009
	sta $2006	
	sta $09		; Zero page - storing high byte here
	lda #$09 	; Load low byte of $2009
	sta $2006
	sta $08		; Zero page - storing low byte here

bkgdouter:
	ldx #0 		; Setup inner loop counter
bkgd:
	; 14 tiles, place them 20 times

	lda backgrounddata_walls,x
	sta $2007
	inx
	cpx #$0E 	; Loop 14 times
	bne bkgd

	lda $2002	; Reset high-low address latch for $2006
	iny 		; Increment outer loop (starts at 0)
	clc			; Clear carry for addition
	lda $08		; Load low byte value for nametable
	adc #32 	; Add 32 to move down one row of tiles
	sta $08		; Store new value here for loop
	lda $09 	; Low high byte value for nametable
	adc #0	 	; if carry is set, should add 1 to $09
	sta $09		; Store new value here for loop

	sta $2006
	lda $08
	sta $2006	; Next address for tile placement now loaded

	cpy #$14 	; Loop 20 times
	bne bkgdouter

; Load the floor of the house.

	ldx #0
	lda $2002
	lda #$22	; Tile address is $2289
	sta $2006
	lda #$89	; Low byte of $2289
	sta $2006
bkgd_floor:
	lda #$01	; Tile $01 is a brick
	sta $2007
	inx
	cpx #$0D	; We want 13 bricks total
	bne bkgd_floor


bkgd_words:		; "Happy Birthday Tommy!" tiles
	lda #$20 	; Tile address is $202C
	sta $09
	lda #$2C    ; Low byte of $202C
	sta $08

	lda $2002
	lda $09
	sta $2006
	lda $08
	sta $2006

	ldx #0
happy:			; "Happy"
	
	lda backgrounddata_words,x
	sta $2007
	inx
	cpx #$05
	bne happy

	clc
	lda $08
	adc #32 	; Add 32 to move down one row
	sta $08
	lda $2002
	lda $09
	sta $2006
	lda $08
	sta $2006
birthday:		; "Birthday"
	; Do not reset x, keep working down
	; list of birthday tiles 

	lda backgrounddata_words,x
	sta $2007
	inx
	cpx #$0D
	bne birthday

	clc
	lda $08
	adc #32
	sta $08
	lda $2002
	lda $09
	sta $2006
	lda $08
	sta $2006


tommy:			; "Tommy!!!"
	; Continue working through list
	; of birthday tiles
	
	lda backgrounddata_words,x
	sta $2007
	inx
	cpx #$15
	bne tommy

	; Reset scroll values so background
	; does not automatically scroll
	lda $2002
	lda #$00
	sta $2005
	sta $2005
	
	; Turn on monitor, turn on NMI
	; (screen refresh), turn on
	; sprites and background
	lda #%00011110
	sta $2001
	lda #$88
	sta $2000


forever:
	jmp forever



initial_palette:
	
	; Background palettes
	db $2A,$27,$0F,$1A  
	db $2A,$23,$33,$1A
	db $2A,$22,$33,$1A
	db $2A,$27,$31,$1A

	; Sprite palettes						
	db $0F,$0F,$27,$16  ; bomb palette
	db $0F,$27,$16,$11  ; cake palette
	db $0F,$07,$27,$25  ; girl palette
	db $0F,$2d,$16,$2d  ; extra palette


sprites:

	db $98, $01, $02, $78 ; Girl #1
	db $98, $02, $42, $85 ; Girl #2

	db $98, $04, $01, $80 ; Cake

	db $30, $0B, $00, $55 ; Explosions!
	db $28, $0B, $00, $5d
	db $28, $0B, $00, $9d
	db $30, $0B, $00, $a5

	db $48, $11, $00, $7d ; Bomb - uh oh!

; Background data
	
backgrounddata_walls:
	
	db $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

backgrounddata_words:
	db $09,$02,$11,$11,$1A				; HAPPY
	db $03,$0A,$13,$15,$09,$05,$02,$1A	; BIRTHDAY
	db $15,$10,$0E,$0E,$1A,$1C,$1C,$1C	; TOMMY!!!


	org $FFFA
	dw nmihandler
	dw startgame
	dw irqhandler

chr_rom_start:

background_tile_start:

	db %00000000	; "Blank" tile
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	; bitplane 2

	db %11101110	; Brick tile
	db %11101110
	db %10111011
	db %10111011
	db %11101110
	db %11101110
	db %10111011
	db %10111011

	db %00010001	; bitplane 2
	db %00010001
	db %01000100
	db %01000100
	db %00010001
	db %00010001
	db %01000100
	db %01000100

	db %00000000	
	db %00011000	; "A"
	db %00100100
	db %01000010
	db %01000010
	db %01111110
	db %01000010
	db %01000010
	db $00, $00, $00, $00, $00, $00, $00, $00	; bitplane 2

	db %00000000
	db %11111000	; "B"
	db %10000100
	db %10000100
	db %11111000
	db %10001000
	db %10000100
	db %11111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00111100	; "C"
	db %01000010
	db %10000000
	db %10000000
	db %10000000
	db %10000010
	db %01111100

	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11100000	; "D"
	db %10010000
	db %10001100
	db %10000110
	db %10000110
	db %10011000
	db %11100000

	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "E"
	db %11111110
	db %10000000
	db %10000000
	db %11111100
	db %10000000
	db %10000000
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "F"
	db %11111110
	db %10000000
	db %10000000
	db %11111100
	db %10000000
	db %10000000
	db %10000000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00111000	; "G"
	db %01000100
	db %10000000
	db %10000000
	db %10011100
	db %10000110
	db %01111100

	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "H"
	db %10000010
	db %10000010
	db %10000010
	db %11111110
	db %10000010
	db %10000010
	db %10000010
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11111110	; "I"
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00


	db %00000000
	db %11111110	; "J"
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %10010000
	db %01110000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "K"
	db %10000100
	db %10011000
	db %11100000
	db %10100000
	db %10011000
	db %10000100

	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "L"
	db %10000000
	db %10000000
	db %10000000
	db %10000000
	db %10000000
	db %10000000
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "M"
	db %11000110
	db %10101010
	db %10010010
	db %10000010
	db %10000010
	db %10000010
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "N"
	db %11000010
	db %10100010
	db %10010010
	db %10001010
	db %10000110
	db %10000010

	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111100	; "O"
	db %10000010
	db %10000010
	db %10000010
	db %10000010
	db %10000010
	db %01111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111100	; "P"
	db %10000010
	db %10000010
	db %11111100
	db %10000000
	db %10000000
	db %10000000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111000	; "Q"
	db %10000100
	db %10000010
	db %10000010
	db %10001010
	db %10000100
	db %01111010
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00111000	; "R"
	db %11000100
	db %10000100
	db %11111100
	db %10001000
	db %10000100
	db %10000110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111100	; "S"
	db %11000010
	db %10000000
	db %01110000
	db %00001100
	db %10000110
	db %11111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11111110	; "T"
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "U"
	db %10000010
	db %10000010
	db %10000010
	db %10000010
	db %10000010
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "V"
	db %10000010
	db %10000010
	db %10000010
	db %01000100
	db %00101000
	db %00010000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %10000010	; "W"
	db %10000010
	db %10000010
	db %10000010
	db %10010010
	db %10101010
	db %01000100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "X"
	db %10000010	
	db %01000100
	db %00101000
	db %00010000
	db %00101000
	db %01000100
	db %10000010
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000	; "Y"
	db %10000010	
	db %01000100
	db %00101000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11111110	; "Z"
	db %00001100	
	db %00011000
	db %00110000
	db %01100000
	db %11000000
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00010000	; "!"
	db %00010000
	db %00010000
	db %00010000
	db %00000000
	db %00010000
	db %00010000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00010000	; "1"
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111100	; "2"
	db %10000010
	db %00000100
	db %00001000
	db %00110000
	db %01000000
	db %11111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %01111100	; "3"
	db %10000010
	db %00000100
	db %00011000
	db %00000100
	db %10000010
	db %01111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00001110	; "4"
	db %00010010
	db %00100010
	db %01111110
	db %00000010
	db %00000010
	db %00000010
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11111110	; "5"
	db %10000000
	db %10000000
	db %11111000
	db %00000100
	db %10000010
	db %01111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00010000	; "6"
	db %00100000
	db %01000000
	db %01111000
	db %10000100
	db %10000100
	db %01111100
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %11111110	; "7"
	db %00000100
	db %00001000
	db %00010000
	db %00100000
	db %01000000
	db %10000000
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00011000	; "8"
	db %00100100
	db %01000010
	db %00111000
	db %01000100
	db %10000010
	db %01111110
	db $00, $00, $00, $00, $00, $00, $00, $00

	db %00000000
	db %00011000	; "9"
	db %00100100
	db %01000010
	db %00111110
	db %00000010
	db %00000010
	db %00000010
	db $00, $00, $00, $00, $00, $00, $00, $00


	; This code here guarantees that your
	; background tiles total 4k 
	; (16 bytes x 256 tiles)
background_tile_end:
	ds 4096-(background_tile_end-background_tile_start)


sprite_tile_start:

	; (Numbers in brackets denote tile #s)

	db %00000000	; "Cake" (0)
	db %00011100
	db %00111110
	db %00111110
	db %00000000
	db %00000000
	db %00000000
	db %00000000

	db %00000000	; "bitplane2"
	db %00000000
	db %00111110
	db %00111110
	db %01111110
	db %01111110
	db %01111110
	db %01111110

	db %00000000	; "Person walk" (1)
	db %00011100
	db %00010000
	db %00010000
	db %00011100
	db %00001100
	db %00001100
	db %00010010

	db %00000000	; "Person walk bp2" 
	db %00000000
	db %00001100
	db %00001100
	db %00001100
	db %00001100
	db %00001100
	db %00000000

	db %00000000	; "Person standing" (2)
	db %00011100
	db %00010000
	db %00010000
	db %00011100
	db %00001100
	db %00001100
	db %00001100

	db %00000000	; "Person standing bp2"
	db %00000000
	db %00001100
	db %00001100
	db %00001100
	db %00001100
	db %00001100
	db %00000000

	db %00000000	; "bomb" (3)
	db %00001000
	db %00111110
	db %01111111
	db %01111111
	db %01111111
	db %00111110
	db %00011100

	db %00011000	; "bomb bp2"
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000

			
	db %00000000	; "Cake 2" (4)
	db %00000000
	db %00000000
	db %00000000	
	db %00010000
	db %00000000
	db %01111100
	db %01111100

	db %00000000	; "Cake 2 bitplane2"
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00111000
	db %01111100
	db %01111100

	db %00000000	; "Person 2 walk" (5)
	db %00111000
	db %00101000
	db %00000000
	db %00111000
	db %00111000
	db %00111000
	db %00000000

	db %00000000	; "Person 2 walk bp2"
	db %00010000
	db %00010000
	db %00111000
	db %00000100
	db %00000000
	db %00000000
	db %00101000

	db %00000000	; "bomb 2" (6)
	db %00001000
	db %00111100
	db %01111110	
	db %01111110	
	db %01111110	
	db %00111100	
	db %00000000


	db %00001000	; "bomb 2 bp2"
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000	

		
	db %00000000	; "Cake 3" (7)
	db %00000000
	db %00000000
	db %00000000	
	db %00011000
	db %00000000
	db %00111100
	db %01111110

	db %00000000	; "Cake 3 bitplane2"
	db %00000000
	db %00000000
	db %00011000
	db %00000000
	db %00111100
	db %00000000
	db %00000000

	db %00111000	; "Person 3 walk" (8)
	db %00101000
	db %00000000
	db %00110000
	db %00110000
	db %00110000
	db %01001000
	db %00000000

	db %00000000	; "Person 3 walk bp2"
	db %00011000
	db %00111000
	db %00000000
	db %00001000
	db %00000000
	db %00000000
	db %00000000

	db %00111000	; "Person 3 stand" (9)
	db %00101000
	db %00000000
	db %00110000
	db %00110000
	db %00110000
	db %00110000
	db %00000000

	db %00000000	; "Person 3 stand bp2"
	db %00011000
	db %00111000
	db %00000000
	db %00001000
	db %00000000
	db %00000000
	db %00000000

	db %00000000	; "bomb 3" (A)
	db %00010000
	db %00111000
	db %01111100	
	db %01111100	
	db %01111100	
	db %00111000	
	db %00000000

	db %00110000	; "bomb 3 bp2"
	db %00010000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000	

	db %00000000	; "bomb explosion!" (B)
	db %00000000
	db %00000000
	db %00000000	
	db %00000000	
	db %00000000	
	db %00000000	
	db %00000000


	db %00000100	; "explosion bp2"
	db %01101010
	db %10111101
	db %01111111
	db %11111110
	db %10111111
	db %01111100
	db %00100110	

	db %00000000	; "Person 4" (C)
	db %00000000
	db %00000000
	db %00011000	
	db %00011000	
	db %00011000	
	db %00111100	
	db %00000000


	db %00000000	; "Person 4 bp2"
	db %00011000
	db %00011000
	db %01111110
	db %00011000
	db %00000000
	db %00000000
	db %00000000	


	db %00000000	; "Person 5" (D)
	db %00000000
	db %00000000
	db %00000000	
	db %00000000	
	db %01010101	
	db %00111111	
	db %01111111


	db %00000000	; "bp2"
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000010
	db %00000000
	db %00000000	


	db %00000000	; "Cake 4" (E)
	db %00000000
	db %00000000
	db %00111000	
	db %00000000	
	db %00111000	
	db %00000000	
	db %01111100


	db %00000000	; "cake 4 bp2"
	db %00000000
	db %00000000
	db %00111000
	db %00111000
	db %00111000
	db %00111000
	db %00000000	

	db %00000000	; "Cake 5" (E)
	db %00000000
	db %00000000
	db %00111100	
	db %00111100	
	db %00111100	
	db %00111100	
	db %01111110


	db %00000000	; "Cake 5 bp2"
	db %00000000
	db %00000000
	db %00000000
	db %00111100
	db %00000000
	db %00111100
	db %00000000	

	db %00000000	; "Cake 6" (F)
	db %00000000
	db %00000000
	db %00011000	
	db %00011000	
	db %00111100	
	db %00111100	
	db %01111110


	db %00000000	; "Cake 6 bp2"
	db %00000000
	db %00000000
	db %00000000
	db %00011000
	db %00000000
	db %00111100
	db %00000000	

	db %00001100
	db %00001000	; "Bomb 4" (10)
	db %00011000
	db %00111100
	db %01111110
	db %01111110
	db %00111100
	db %00011000


	db %00001100	; "bp2"
	db %00001000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000
	db %00000000		
	
	db %00011000
	db %00100100	; "Girl" (11)
	db %00100100
	db %00111100
	db %00111100
	db %00111100
	db %01111110
	db %00000000


	db %00000000	; "bp2"
	db %00011000
	db %00011000
	db %00111100
	db %00011000
	db %00111100
	db %01111110
	db %00100100

	db %00110000
	db %01100000	; "Sideview girl" (12)
	db %01100000
	db %01110000
	db %01110000
	db %01111000
	db %11111100
	db %00000000


	db %00000000	; "bp2"
	db %00010000
	db %00010000
	db %00111000
	db %00110000
	db %01111000
	db %11111100
	db %01001000

	db %00011000
	db %00010000	; "Boy" (13)
	db %00010000
	db %00011100
	db %00011000
	db %00011000
	db %01111000
	db %01001100


	db %00000000	; "bp2"
	db %00001000
	db %00001000
	db %00011110
	db %00111000
	db %00011000
	db %01111000
	db %01001100

	db %00011000
	db %00000000	; "Boy standing" (14)
	db %00000000
	db %00111100
	db %00011000
	db %00011000
	db %00011000
	db %00111100


	db %00000000	; "bp2"
	db %00011000
	db %00011000
	db %00111100
	db %00111100
	db %00111100
	db %00011000
	db %00111100


	db %01110000
	db %01010000	; "Boy 2 walking" (15)
	db %01000000
	db %00000000
	db %00110000
	db %00110000
	db %00110000
	db %01001000


	db %00000000	; "bp2"
	db %00110000
	db %00111000
	db %00110000
	db %00110000
	db %00111000
	db %00110000
	db %00000000

	db %01110000
	db %01010000	; "Boy 2 standing" (16)
	db %01000000
	db %00000000
	db %00110000
	db %00110000
	db %00110000
	db %00110000


	db %00000000	; "bp2"
	db %00110000
	db %00111000
	db %00110000
	db %00110000
	db %00111000
	db %00110000
	db %00000000

	db %00000000
	db %00000000	; "tiny man" (17)
	db %00000000
	db %00010000
	db %00011000
	db %00010000
	db %00010000
	db %00010000


	db %00000000	; "bp2"
	db %00000000
	db %00010000
	db %00010000
	db %00011100
	db %00010000
	db %00000000
	db %00000000

	db %00000000
	db %00000000	; "tiny man walking" (18)
	db %00000000
	db %00010000
	db %00011000
	db %00010000
	db %00010000
	db %00101000


	db %00000000	; "bp2"
	db %00000000
	db %00010000
	db %00010000
	db %00011100
	db %00010000
	db %00000000
	db %00000000


sprite_tile_end

	
chr_rom_end:

; Pad chr-rom to 8k (to make valid file)
	ds 8192-(chr_rom_end-chr_rom_start)

