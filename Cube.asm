;Constants
XOFFSET	= 160
YOFFSET = 101

;External absolute addresses
DrawCube 	= draw_cube
MA 			= ma_	;ma variable
MB 			= mb_	;mb variable
MC 			= mc_	;mc variable
MD 			= md_	;md variable
ME 			= me_	;me variable
MF			= mf_	;mf variable
MG 			= mg_	;mg variable
MH 			= mh_	;mh variable
MI 			= mi_	;mi variable

;local addresses
ma_ 		= ma_var + 1	;ma variable
mb_ 		= mb_var + 1	;mb variable
mc_ 		= mc_var + 1	;mc variable
md_ 		= md_var + 1	;md variable
me_ 		= me_var + 1	;me variable
mf_			= mf_var + 1	;mf variable
mg_ 		= mg_var + 1	;mg variable
mh_ 		= mh_var + 1	;mh variable
mi_ 		= mi_var + 1	;mi variable

draw_cube
		;cube point 1 (1,1,1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
mc_var	lda #0
		clc 
mf_var	adc #0
mi_var	adc #0
		tax
		lda prj_tbl,x
		sta multiply.MB 	;prj_z
		
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
ma_var	lda #0
		clc
md_var	adc #0
mg_var	adc #0
		sta multiply.MA 	;x
		;p1x = 128 + ((x * prj_z) / 256)
		jsr multiply.MultAB	;result / 256 in A
		clc
		adc #XOFFSET		;add offset
		sta x1a+1
		sta x1b+1
		sta x1c+1
		
		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
mb_var	lda #0
		clc
me_var	adc #0
mh_var	adc #0
		sta multiply.MA		;y
		;p1y = 100 + ((y * prj_z) / 256)
		jsr multiply.MultAB	;result / 256 in A
		clc
		adc #YOFFSET		;add offset
		sta y1a+1
		sta y1b+1
		sta y1c+1
		
		;cube point 2 (1,-1,1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mc_
		sec 
		sbc mf_
		adc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda ma_
		sec
		sbc md_
		adc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x2a+1
		sta x2b+1
		sta x2c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda mb_
		sec
		sbc me_
		adc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y2a+1
		sta y2b+1
		sta y2c+1

		;cube point 3 (1,1,-1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mc_
		clc 
		adc mf_
		sec
		sbc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda ma_
		clc
		adc md_
		sec
		sbc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x3a+1
		sta x3b+1
		sta x3c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda mb_
		clc
		adc me_
		sec
		sbc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y3a+1
		sta y3b+1
		sta y3c+1

		;cube point 4 (1,-1,-1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mc_
		sec 
		sbc mf_
		sbc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda ma_
		sec
		sbc md_
		sbc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x4a+1
		sta x4b+1
		sta x4c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda mb_
		sec
		sbc me_
		sbc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y4a+1
		sta y4b+1
		sta y4c+1

		;cube point 5 (-1,1,1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mf_
		sec 
		sbc mc_
		clc
		adc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda md_
		sec
		sbc ma_
		clc
		adc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x5a+1
		sta x5b+1
		sta x5c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda me_
		sec
		sbc mb_
		clc
		adc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y5a+1
		sta y5b+1
		sta y5c+1

		;cube point 6 (-1,-1,1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mi_
		sec 
		sbc mf_
		sbc mc_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda mg_
		sec
		sbc md_
		sbc ma_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x6a+1
		sta x6b+1
		sta x6c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda mh_
		sec
		sbc me_
		sbc mb_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y6a+1
		sta y6b+1
		sta y6c+1

		;cube point 7 (-1,1,-1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda mf_
		sec 
		sbc mc_
		sbc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda md_
		sec
		sbc ma_
		sbc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x7a+1
		sta x7b+1
		sta x7c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda me_
		sec
		sbc mb_
		sbc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y7a+1
		sta y7b+1
		sta y7c+1
		
		;cube point 8 (-1,-1,-1)
		;z = (cube[p][0] * mc) + (cube[p][1] * mf) + (cube[p][2] * mi)
		lda #0
		sec 
		sbc mc_
		sbc mf_
		sbc mi_
		tax
		lda prj_tbl,x
		sta multiply.MB
		
		;x = (cube[p][0] * ma) + (cube[p][1] * md) + (cube[p][2] * mg)
		lda #0
		sec
		sbc ma_
		sbc md_
		sbc mg_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #XOFFSET
		sta x8a+1
		sta x8b+1
		sta x8c+1

		;y = (cube[p][0] * mb) + (cube[p][1] * me) + (cube[p][2] * mh)
		lda #0
		sec
		sbc mb_
		sbc me_
		sbc mh_
		sta multiply.MA
		jsr multiply.MultAB
		clc
		adc #YOFFSET
		sta y8a+1
		sta y8b+1
		sta y8c+1
		inc $d020

		;Draw the lines on BP 0
		lda #1
		sta lineCol.Colour
x1a		lda #0
		sta lineCol.X1
y1a		lda #0
		sta lineCol.Y1
x3a		lda #0
		sta lineCol.X2
y3a		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #3
		sta lineCol.Colour
x1b		lda #0
		sta lineCol.X1
y1b		lda #0
		sta lineCol.Y1
x2a		lda #0
		sta lineCol.X2
y2a		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #1
		sta lineCol.Colour
x1c		lda #0
		sta lineCol.X1
y1c		lda #0
		sta lineCol.Y1
x5a		lda #0
		sta lineCol.X2
y5a		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #3
		sta lineCol.Colour
x6a		lda #0
		sta lineCol.X1
y6a		lda #0
		sta lineCol.Y1
x5b		lda #0
		sta lineCol.X2
y5b		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #2
		sta lineCol.Colour
x6b		lda #0
		sta lineCol.X1
y6b		lda #0
		sta lineCol.Y1
x2b		lda #0
		sta lineCol.X2
y2b		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #2
		sta lineCol.Colour
x6c		lda #0
		sta lineCol.X1
y6c		lda #0
		sta lineCol.Y1
x8a		lda #0
		sta lineCol.X2
y8a		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		inc $d020

		lda #2
		sta lineCol.Colour
x4a		lda #0
		sta lineCol.X1
y4a		lda #0
		sta lineCol.Y1
x2c		lda #0
		sta lineCol.X2
y2c		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		lda #2
		sta lineCol.Colour
x4b		lda #0
		sta lineCol.X1
y4b		lda #0
		sta lineCol.Y1
x8b		lda #0
		sta lineCol.X2
y8b		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		lda #3
		sta lineCol.Colour
x4c		lda #0
		sta lineCol.X1
y4c		lda #0
		sta lineCol.Y1
x3b		lda #0
		sta lineCol.X2
y3b		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		lda #3
		sta lineCol.Colour
x7a		lda #0
		sta lineCol.X1
y7a		lda #0
		sta lineCol.Y1
x8c		lda #0
		sta lineCol.X2
y8c		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		lda #1
		sta lineCol.Colour
x7b		lda #0
		sta lineCol.X1
y7b		lda #0
		sta lineCol.Y1
x3c		lda #0
		sta lineCol.X2
y3c		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		lda #1
		sta lineCol.Colour
x7c		lda #0
		sta lineCol.X1
y7c 	lda #0
		sta lineCol.Y1
x5c		lda #0
		sta lineCol.X2
y5c		lda #0
		sta lineCol.Y2
		jsr lineCol.Line
		dec $d020

		rts
