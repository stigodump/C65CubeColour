; Signed 8-bit multiply -> 8-bit result
; MA -128 to 127, MB 0 to 255
; (MA*MB)/256 -> result Accumalator
; Uses A, X, MB not changed

	.section zero_page
MB 		.byte ?
MA		.byte ?
	.send 

MultAB			ldx #0
				lda MA
				bpl +
				neg
				sta MA
				inx 
				
+				lda #0
    			clc

 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+				cpx #0
				beq +
				eor #$ff
				ldx MA
				bne +
				inc a 

+				rts


