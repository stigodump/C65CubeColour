;External absolute addresses
CalcMatrix 	= calc_matrix 	;Calculate matix routine address
X			= sx			;X rotation value
Y			= sy			;Y rotation value
Z			= sz			;Z rotation value

;loacl calls to base page address
sx		= x_var + 1		;X rotation value
sy		= y_var + 1		;Y rotation value
sz		= z_var + 1		;Z rotation value
v1		= v1_var + 1	;v1 variable
v2 		= v2_var + 1	;v2 variable
v3 		= v3_var + 1	;v3 variable
v4 		= v4_var + 1	;v4 variable
v5 		= v5_var + 1	;v5 variable
v6 		= v6_var + 1	;v6 variable
v7 		= v7_var + 1	;v7 variable
v8 		= v8_var + 1	;v8 variable
v9 		= v9_var + 1	;v9 variable
v10 	= v10_var + 1	;v10 variable
t1 		= t1_var + 1	;lt1 variable
t2 		= t2_var + 1	;lt2 variable
t3 		= t3_var + 1	;lt3 variable
t4 		= t4_var + 1	;lt4 variable
md 		= md_var + 1	;md variable
me 		= me_var + 1	;me variable
mg 		= mg_var + 1	;mg variable
mh 		= mh_var + 1	;mh variable

calc_matrix
		;v1 = sy - sz
y_var	lda #0 		;Y
		sec 
z_var	sbc #0 		;Z
		sta v1

		;v7 = v1 + sx (v7 = sx + sy - sz)
		clc
		adc sx
		sta v7

		;v2 = sy + sz
		lda	sy
		clc
		adc sz
		sta v2

		;v5 = v2 + sx (v5 = sx + sy - sz)
		clc
		adc sx
		sta v5

		;v3 = sx + sz
x_var	lda #0 		;X 
		clc
		adc sz
		sta v3

		;v4 = sx - sz
		lda sx
		sec
		sbc sz
		sta v4

		;v6 sx - v1 (v6 = sx - sy - sz)
		lda sx
		sec
		sbc v1
		sta v6

		;v8 = v2 - sx (v8 = sy - sz - sx)
		lda v2
		sec
		sbc sx
		sta v8

		;v9 = sy - sx
		lda sy
		sec
		sbc sx
		sta v9

		;v10 = sy + sx
		lda sy
		clc
		adc sx
		sta v10

		;MC = sin(sy)
		ldy sy
		lda sin_tbl,y
		sta cube.MC

v1_var	ldx #0 		;v1
v2_var	ldy #0 		;v2

		;MA = cos(v1) + cos(v2) / 2
		lda cos_tbl,x
		clc
		adc cos_tbl,y
		asr
		sta cube.MA

		;MB = sin(v1) - sin(v2) / 2
		lda sin_tbl,x
		sec
		sbc sin_tbl,y
		asr
		sta cube.MB

v9_var	ldx #0  	;v9
v10_var	ldy #0 		;v10

		;MF = sin(v9) - sin(v10) / 2
		lda sin_tbl,x
		sec
		sbc sin_tbl,y
		asr
		sta cube.MF

		;MI = cos(v9) + cos(v10) / 2
		lda cos_tbl,x
		clc
		adc cos_tbl,y
		asr
		sta cube.MI

v5_var	ldx #0 		;v5
v6_var	ldy #0 		;v6

		;t1 = cos(v6) - cos(v5) / 2
		lda cos_tbl,y
		sec
		sbc cos_tbl,x
		asr
		sta t1

		;t2 = sin(v5) - sin(v6) / 2
		lda sin_tbl,x
		sec
		sbc sin_tbl,y
		asr
		sta t2

v7_var	ldx #0 		;v7
v8_var	ldy #0 		;v8

		; t3 = 0 - sin(v7) - sin(v8) / 2
		lda #0
		sec
		sbc sin_tbl,x
		sec
		sbc sin_tbl,y
		asr
		sta t3

		;t4 = cos(v8) - cos(v7) / 2
		lda cos_tbl,y
		sec
		sbc cos_tbl,x
		asr
		sta t4

v3_var	ldx #0 		;v3
v4_var	ldy #0		;v4

		;md = sin(v3) - sin(v4) / 2
		lda sin_tbl,x
		sec
		sbc sin_tbl,y
		asr
		sta md

		;MD = md + (t1 + t4) / 2
t1_var	lda #0		;t1
		clc
t4_var	adc #0		;t4
		asr
		clc
md_var	adc #0		;md
		sta cube.MD

		;me = cos(v3) + cos(v4) / 2
		lda cos_tbl,x
		clc
		adc cos_tbl,y
		asr
		sta me

		;ME = me + (t2 + t3) / 2
t2_var	lda #0		;t2
		clc
		adc t3
		asr
		clc
me_var	adc #0		;me
		sta cube.ME

		;mg = cos(v4) - cos(v3) / 2
		lda cos_tbl,y
		sec
		sbc cos_tbl,x
		asr
		sta mg

		;MG = mg + (t3 - t2) / 2
t3_var	lda #0		;t3
		sec
		sbc t2
		asr
		clc
mg_var	adc #0		;mg
		sta cube.MG

		;mh = sin(v3) + sin(v4) / 2
		lda sin_tbl,x
		clc
		adc sin_tbl,y
		asr
		sta mh

		;MH = mh + (t1 - t4) / 2
		lda t1
		sec
		sbc t4
		asr
		clc
mh_var 	adc #0		;mh
		sta cube.MH

		rts
