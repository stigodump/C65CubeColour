;******************************************************************
;
; Rotate a cube and draw onto two bitplanes in C65 mode 
;
;	Auther: R Welbourn
;	Discord: Stigodump
;	Date: 17/11/2021
;	Assembler: 64TAS Must be at least build 2625
;	64tass-1.56.2625\64tass.exe -a Build.asm -o Build.prg --tab-size=4
;	Xemu: Tested using Xemu - ROM 911001 & 920246
;
;******************************************************************

;Target CPU
	.cpu "4510"

ZERO_PAGE			= $c4
BASIC_CODE			= $2001
MAIN_CODE 			= $2020

* = ZERO_PAGE
	.dsection zero_page
	.cerror * > ZERO_PAGE + $08, "Too many ZP variables"

* = BASIC_CODE
	.dsection basic_code
	.cerror * > BASIC_CODE + MAIN_CODE - BASIC_CODE, "Not enough space"

* = MAIN_CODE
	.dsection main_code
	.cerror * > $5fff, "Not enough space"

	.section basic_code
		;.byte $00										;Start
		.byte $0a,$20,$0a,$00,$fe,$02,$20,$30,$00 		;10 BANK 0
		.byte $16,$20,$14,$00,$9e,$38,$32,$32,$34,$00	;20 SYS8224 ($2020)
		.byte $00,$00									;End				
	.send

	.section main_code
				;Set MONITOR memory MAP
				lda $0114
				ldx $0115
				ldy $0116
				ldz $0117
				map
				eom

				;Set DMAgic to F018B
				lda #%00000001
				tsb $d703

				;Set 3.5Mhz
				lda #%01000000
				trb $d054

				;Set Bitplanes to first 128K
				lda #%00000111
				trb $d07c

				;Save and update IRQ interrupt vector
				sei
 				lda $314
				sta return+1
				lda $315
				sta return+2
				lda #<Int
				sta $314
				lda #>Int
				sta $315

				;Set raster compare to 245
				lda #%10000000
				trb $d011
				lda #<245
				sta $d012
				
				;Set first four colours in colour pallet
				ldx #15
				lda #0
				;Black
				sta $d100
				sta $d200
				sta $d300
				;Reb
				stx $d101
				sta $d201
				sta $d301
				;Green
				sta $d102
				stx $d202
				sta $d302
				;Blue
				sta $d103
				sta $d203
				stx $d303
	
				;Set two bitplanes to $8000 Bank0 & Bank1
				lda #%10001000
				sta $d033
				sta $d034
				lda #%00000011
				sta $d032
				lda #%01010000
				sta $d031

				;Clear whole BP1 and BP2
				lda #0
				sta $d702
				lda #>dma_clrscrn
				sta $d701
				lda #<dma_clrscrn
				sta $d700
				cli

Wait			bra	Wait

Int				;Interrupt entry point
				lda #1
				sta $d020

				;Clear part of BP1 and BP2
				lda #0
				sta $d702
				lda #>dma_clrcube
				sta $d701
				lda #<dma_clrcube
				sta $d700

				inc $d020
				
				;Set rotation angles and calculate matrix
				lda xa
				sta matrix.X
				lda ya
				sta matrix.Y
				lda za
				sta matrix.Z
				jsr matrix.CalcMatrix

				inc $d020

				;Rotate and draw cube
				jsr cube.DrawCube

				lda colour
				sta $d020

				;Increment X Y rotation angles
				inc xa
				dec timer
				bne return
				lda #2
				sta timer
				inc ya
				
return			jmp $2000	;Code will set this return address

timer			.byte 1
xa				.byte 0
ya				.byte 0
za 				.byte 0
xi				.byte 0
yi				.byte 0
zi 				.byte 0
colour			.byte 0

;DMA job to clear whole of both bitplanes
dma_clrscrn	.byte %00000111 ;command low byte: FILL+CHAIN
			.word 8000		;40x200 = 8000
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 1			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

			.byte %00000011	;command low byte: FILL
			.word 8000		;40x200 = 8000
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 0			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

;DMA job to clear BP1 and BP2 where cube is drawn
dma_clrcube	.byte %00000111 ;command low byte: FILL+CHAIN
			.word 4864		;40x200 = 8000
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word 34496		;destination address
			.byte 1			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

			.byte %00000011	;command low byte: FILL
			.word 4864		;40x200 = 8000
			.word 0			;source address/fill value
			.byte 0			;source Bank
			.word 34496		;destination address
			.byte 0			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

matrix		.binclude "Matrix.asm"
cube		.binclude "Cube.asm"
multiply	.binclude "Multiply.asm"
lineCol 	.binclude "LineColour.asm"

			.send