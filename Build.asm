;Mega 65

;Target CPU
	.cpu "4510"

ZERO_PAGE			= $c4
START_INT_CODE		= $1800
BASIC				= $2000
CODE	 			= $2020
DRAW_COL_PAGE 		= $2a00
DRAW_BPLN_PAGE 		= $2b00
SIN_TABLE			= $2c00
PRJ_TABLE			= $2d00

* = ZERO_PAGE
	.dsection zero_page
	.cerror * > ZERO_PAGE + $08, "Too many ZP variables"

* = START_INT_CODE
	.dsection start_int_code
	.cerror * > START_INT_CODE + $1ff, "Not enough space"

* = DRAW_COL_PAGE
	.dsection draw_col_page
	.cerror * > DRAW_COL_PAGE + $ff, "Not enough space"

* = DRAW_BPLN_PAGE
	.dsection draw_bpln_page
	.cerror * > DRAW_BPLN_PAGE + $ff, "Not enough space"

* = BASIC
	.byte $00										;Start
	;.byte $0a,$20,$0a,$00,$fe,$02,$20,$30,$00		;10 BANK 0
	.byte $0b,$20,$14,$00,$9e,$36,$31,$34,$34,$00	;20 SYS6144 ($1800)
	.byte $00,$00									;End				

			.section start_int_code
Start			sei
				
				lda $0114
				ldx $0115
				ldy $0116
				ldz $0117
				map
				;eom
				;pla
				lda $01
				;Bank IO in via C64 mechanism
				;lda #$35
				;sta $01
				;End MAP sequence
				eom 
				;thus allowing interrupts to occur again EOM
				;Map all C65 ROMS
				;lda #%10000000
				;tsb $d030
				
				;Save and update IRQ interrupt vector
 				lda $314
				sta return+1
				lda $315
				sta return+2
				lda #<Int
				sta $314
				lda #>Int
				sta $315

				lda #%10000000
				tsb $d011
				
				ldx #15
				lda #0
				stx $d101
				sta $d201
				sta $d301
				sta $d102
				sta $d202
				stx $d302
				ldy	#8
				sty $d103
				ldy #10
				sty $d203
				sta $d303
	
				lda #%10001000
				sta $d033
				sta $d034
				lda #%00000011
				sta $d032
				lda #%01010000
				sta $d031

				lda #0
				sta $d702
				lda #>dma_job2
				sta $d701
				lda #<dma_job2
				sta $d700
				cli

-				jsr ($032a)
				cmp	#$58
				beq XKeyP
				cmp #$59
				beq YKeyP
				cmp #$5a
				beq ZKeyP
				cmp	#$d8
				beq XKeyM
				cmp #$d9
				beq YKeyM
				cmp #$da
				beq ZKeyM
				bra -
XKeyP			inc xa
				lda #02
				sta colour
				bra -
YKeyP			inc ya
				lda #07
				sta colour
				bra -
ZKeyP			inc za
				lda #10
				sta colour
				bra -
XKeyM			dec xa
				lda #03
				sta colour
				bra -
YKeyM			dec ya
				lda #08
				sta colour
				bra -
ZKeyM			dec za
				lda #11
				sta colour
				bra -

Int				;Clear all CPU mapping
				
				lda #1
				sta $d020

				lda #0
				sta $d702
				lda #>dma_job1
				sta $d701
				lda #<dma_job1
				sta $d700

				inc $d020

				lda xa
				sta matrix.X
				lda ya
				sta matrix.Y
				lda za
				sta matrix.Z
				jsr matrix.CalcMatrix

				inc $d020

				jsr cube.DrawCube

				lda colour
				sta $d020

				inc za
				dec timer
				bne return
				lda #2
				sta timer
				inc ya
				
return			jmp $2000	;Code will set this return address

timer			.byte 1
xa				.byte 0
ya				.byte 0
za 				.byte 5
colour			.byte 0

dma_job2	.byte %00000111 ;command low byte: FILL+CHAIN
			.word 8000		;40x200 = 8000
			.word 0000		;fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 1			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo
dma_job1	.byte %00000011	;command low byte: FILL
			.word 8000		;40x200 = 8000
			.word 0000		;fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 0			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

		.send

* = CODE

matrix		.binclude "Matrix.asm"
cube		.binclude "Cube.asm"
multiply	.binclude "Multiply.asm"

sin_tbl 	.for s := 0, s < 256, s += 1
				.char (63.0 * sin((s * (360.0 / 256.0)) * (pi / 180.0)));
			.next

cos_tbl		.for c := 0, c < 256, c += 1
				.char (63.0 * cos((c * (360.0 / 256.0)) * (pi / 180.0)));
			.next

prj_tbl 	.for i := 0, i < 128, i += 1
				.byte (128.0 / (256.0 - i)) * 256.0
			.next
			.for i := -128, i < 0, i += 1
				.byte (128.0 / (256.0 - i)) * 256.0
			.next

		.section draw_col_page
;lineCol 		.binclude "LineColour.asm"
		.send

		.section draw_bpln_page
lineBpln		.binclude "LineBPlane.asm"
		.send


