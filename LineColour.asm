;******************************************************************
;
; Draw line X 0 to 255 & Y 0 to 199 onto two bitplanes
; Colour 0 to 3. Code runs on Base Page (Zero Page)
;
;	Auther: R Welbourn
;	Discord: Stigodump
;	Date: 12/03/2021
;	Assembler: 64TASS Must be at least build 2625
;
; There are a few ways to improve the line drawing routine. At the
; moment it will only draw on the X axis to pixel 255. This could 
; be changed to draw a line with X 256 pixels long from anywhere on
; the screen with little change, as the line drawing loop can draw
; 256 pixels from any point on the screen. I'm sure a couple of
; cycles per iteration of the line drawing loop can be saved with a
; mask overflow detection reimplementation. And possibly other
; changes.
;
;******************************************************************

;VICIII constants
BPX 	= $d03c
BPY 	= $d03d
B0PIX 	= $d040
B1PIX	= $d041

;4510 Instruction Constants
INC_ABS	= $ee
DEC_ABS = $ce
TSB_ABS = $0c
TRB_ABS = $1c

		.align $100

DRAW_COL_PAGE	= *

;External adresses
Line 	= DRAW_COL_PAGE + drwline	;Draw line routine address
Colour 	= DRAW_COL_PAGE + col 		;Colour to draw value
X1		= DRAW_COL_PAGE + x1var + 1	;X1 line value
X2		= DRAW_COL_PAGE + x2var + 1	;X2 line value
Y1		= DRAW_COL_PAGE + y1var + 1	;Y1 line value
Y2		= DRAW_COL_PAGE + y2var + 1	;Y2 line value
		
;Operates in Base Page (Zero Page)  
		.logical $00

			;Down the screen
-			tay
			lda #INC_ABS
			bra +

invert		ldx x1var + 1
			ldy x2var + 1
			stx	x2var + 1
			sty x1var + 1
			ldx y1var + 1
			ldy y2var + 1
			stx y2var + 1
			sty y1var + 1
			bra x2var

			;Set Base Page register
drwline		tba
			pha
			lda #>DRAW_COL_PAGE
			tab
				
			;dx = x1-x2 or x2-x1 smallest from bigest
x2var		lda #*	;x2 variable
			sec 
x1var		sbc #*	;x1 variable
			blt invert
			sta dx1mem+1
			sta dx2mem+1
			taz

			;Set pointer to where first byte of first pixel is
			lda x1var + 1
			lsr
			lsr
			lsr
			sta BPX
			lda x1var + 1
			and #%00000111
			tax 
			lda y1var + 1
			sta BPY

			;dy = y1-y2
y2var		lda #*	;y2 variable
			sec
y1var		sbc #*	;y1 variable

			;Will Y go up the screen or down the screen
			bge -
			;Up the screen
			neg
			tay
			lda #DEC_ABS

			;Set the instruction in the line drawing code
+			sta incdecy
			sta decincy
			sty dy1mem+1
			sty dy2mem+1

			;Set the Clear or Set bits for each bitplane
			;for the coloured line
			asr col
			lda #TRB_ABS
			bcc +
			lda #TSB_ABS
+			sta dxcolbit0
			sta dycolbit0
			asr col
			lda #TRB_ABS
			bcc +
			lda #TSB_ABS
+			sta dxcolbit1
			sta dycolbit1
			
			tya
			asr a

			;Find longest line axis X or Y for gradient
			;line draw to use
			cpy dx1mem+1
			blt Gradx
			sec
			cpy #0
			bne Grady
			bra exit_line

			;draw line dx+ dy+/- dy<dx
-			inx
dy1mem		adc #*	;dy
			bcc	+
decincy		inc BPY
Gradx
dx1mem		sbc #*	;dx
+			tay
			lda mask,x
			bne +
			inc BPX
			tax
			lda #%10000000
+
dxcolbit0	tsb B0PIX
dxcolbit1	tsb B1PIX
			tya
			dez
			bne	-
			pla
			tab
			rts

			;draw line dx+ dy+/- dy>dx
-
dx2mem		adc #*	;dx
			bcc	+
			inx
Grady		
dy2mem		sbc #*	;dy
+			taz
incdecy		inc BPY
			lda mask,x
			bne	+
			inc BPX
			tax
			lda #%10000000
+			
dycolbit0	tsb B0PIX
dycolbit1	tsb B1PIX
			tza
			dey
			bne	-
exit_line	pla
			tab
			rts

col 		.byte 0
mask		.byte %10000000
			.byte %01000000
			.byte %00100000
			.byte %00010000
			.byte %00001000
			.byte %00000100
			.byte %00000010
			.byte %00000001
			.byte %00000000	;overflow inc BPX
		.here	
