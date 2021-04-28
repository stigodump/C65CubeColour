;VICIII Constants

BPX 	= $d03c
BPY 	= $d03d
B0PIX 	= $d040
B1PIX	= $d041
INC_ABS	= $ee
DEC_ABS = $ce
TSB_ABS = $0c
TRB_ABS = $1c

Line 	= DRAW_COL_PAGE + drwline	;Draw line routine address
Colour 	= DRAW_COL_PAGE + col 		;Colour to draw in value
X1		= DRAW_COL_PAGE + x1var + 1	;X1 line value
X2		= DRAW_COL_PAGE + x2var + 1	;X2 line value
Y1		= DRAW_COL_PAGE + y1var + 1	;Y1 line value
Y2		= DRAW_COL_PAGE + y2var + 1	;Y2 line value

		.logical $00

-			tay
			lda #INC_ABS
			bra +

invert		ldx X1
			ldy X2
			stx	X2
			sty X1 
			ldx Y1
			ldy Y2
			stx Y2
			sty Y1
			bra x2var

drwline		tba
			pha
			lda #>DRAW_COL_PAGE
			tab
				
			;dx = x1-x2
x2var		lda #*	;x2 variable
			sec 
x1var		sbc #*	;x1 variable
			blt invert
			sta dx1mem+1
			sta dx2mem+1
			taz

			lda X1
			lsr
			lsr
			lsr
			sta BPX
			lda X1
			and #%00000111
			tax 
			lda Y1
			sta BPY

			;dy = y1-y2
y2var		lda #*	;y2 variable
			sec
y1var		sbc #*	;y1 variable
			bge -

			neg
			tay
			lda #DEC_ABS

+			sta incdecy
			sta decincy
			sty dy1mem+1
			sty dy2mem+1

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
			
			lda #0

			cpy dx1mem+1
			bge Grady
			sec
			bra Gradx

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
			pla
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
