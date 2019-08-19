#x29, x30, x31 row 1 row 2 row 3
#x28 calculated median value
#x27 row counter
#x26 column counter
#x25 pixel counter
#x24 array counter
#x23 shift value for hanging pixels (3,2,1,3,2,1)
#x22 (Pixel shift (0 for first pixel, 3 for middle pixels))
#x21 (word handler offset)
#x20 (word address offset)
#x19 (Array base memory address)
#x18 middle row median values
#x17 x18 shift offset
#x15-x7 temp


.Main:
initialLoad:
	nop

	addi x21, x0, 72 ##uncomment for synth
	## addi x21, x0, 1024 ##uncomment for sim
	addi x23, x0, 1755
	addi x24, x21, 1920
	addi x19, x21, 1920

	call loadNewWord

	addi x18, x30, 0
	andi x18, x18, 7
	addi x17, x0, 3

	addi x22, x0, 0

	call pixelToArray
	nop
	call pixelToArray
	nop
	call pixelToArray
	nop

	##Array is full

	call copyArray
	nop
	call findMedian  #find median value out of 9
	nop
	call updatePixel
	nop

.Loop1:
	addi x7, x0, 36
	bge x24, x7, arrayOverflow ##(Check array overflow)
	
	addi x7, x0, 10
	bge x25, x7, pixelOverflow
	
	addi x7, x0, 58
	bge x26, x7, colOverflow
	
	addi x7, x0, 78
	bge x27, x7 rowOverflow
	
	call pixelToArray
	nop
	call copyArray
	nop
	call findMedian  #find median value out of 9
	nop
	call updatePixel
	nop
	
	j .Loop1
	nop

loadNewWord:
	addi x8, x0, 3
	andi x7, x23, 3 #new word shift value
	sub x7, x8, x7
	
	lw x29, 0(x21)
	addi x9, x21, -72
	sw x29, 0(x9)
	srl x29, x29, x7
	
	addi x11, x21, 24
	addi x9, x9, 24
	lw x30, 0(x11)
	sw x30, 0(x9)
	srl x30, x30, x7
	
	addi x11, x21, 48
	addi x9, x9, 24
	lw x31 0(x11)
	sw x30, 0(x9)
	srl x31, x31, x7
	
	ret
	nop
	
pixelToArray: #(Handles adding full pixel stored in register to array)
	srl x29, x29, x22 #Shift pixel to LSB (0 for first pixel, 3 for middle, special handler for bits 31-32)
	andi x7, x29, 7 #Mask pixel
	sw x7, 0(x24) #Store pixel to array
	addi x24, x24, 4 #(Array offset increment)

	srl x30, x30, x22
	andi x7, x30, 7
	sw x7, 0(x24)
	addi x24, x24, 4
	
	srl x31, x31, x22
	andi x7, x31, 7
	sw x7, 0(x24)
	addi x24, x24, 4
	
	addi x25, x25, 1 #(pixel offset, for checking word overflow)
	addi x26, x26, 1
	addi x22, x0, 3
	
	ret
	nop
	
arrayOverflow: #(after adding 9th pixel to array, move back to base array address)
	addi x24, x0, 0
	j .Loop1
	nop
	
pixelOverflow: #(pixels are 3 bit values, word is 32 bits, hanging pixel at end/beginning of word (2 extra, 1 extra, 0 extra, repeating)
	srli x23, x23, 2 #new word shift handler(init 100100 for pattern 3,2,1,3,2,1)
	andi x8, x23, 3
	
	addi x21, x21, 4 ##next word
	srl x29, x29, x22
	lw x7, 0(x21)
	sll x7, x7, x8
	or x29, x29, x7 ##bottom bits from current word, new bits from next word
	
	addi x11, x21, 24
	srl x30, x30, x22
	lw x7, 0(x11)
	sll x7, x7, x8
	or x30, x30, x7 ##bottom bits from current word, new bits from next word
	
	addi x11, x21, 48
	srl x31, x31, x22
	lw x7, 0(x11)
	sll x7, x7, x8
	or x31, x31, x7 ##bottom bits from current word, new bits from next word
	
	addi x22, x0, 0
	
	call pixelToArray
	addi x25, x0, 0 
	call copyArray
	nop
	call findMedian
	nop
	call writePixel
	nop
	j .Loop1
	nop
	
colOverflow: ##New row
	addi x23, x0, 1755
	addi x22, x0, 0
	addi x25, x0, 0
	addi x26, x0, 0
	addi x27, x27, 1 #(row counter)
	
	call loadNewWord
	nop
	
	addi x18, x30, 0
	andi x18, x18, 7
	addi x17, x0, 3
	
	call pixelToArray
	nop
	call pixelToArray
	nop
	call pixelToArray
	nop
	call copyArray
	nop
	call findMedian
	nop
	call updatePixel
	nop
	j .Loop1
	nop
	
rowOverflow: ##end of image
	ecall
	
findMedian: ##quicksort median finder

	addi x7, x19, 36 ##array copy base address
	addi x8, x0, 0 ##int i = 0
	addi x11, x0, 0 ##int j = 0
	addi x15, x0, 20 ##check if i < 9
	addi x13, x0, 36 ##check if j < 5

	.iLoop:
		add x7, x7, x8
		lw x9, 0(x7) ##temp_min = ax[i]

		addi x11, x8, 4 ##j = i+1

			.jLoop:
				add x7, x7, x11 ##pointer to ax[j]
				lw x10, 0(x7) ##ax[j]
				bgt x9, x10 updateTempMin ##tempmin > ax[j]
				addi x11, x11, 4
				bge x11, x13 .jEnd
				nop
			j .jLoop
			nop
				
				updateTempMin:
				addi x9, x10, 0 ##ax[j] to tempmin
				addi x14, x11, 0 ##j value 
				addi x11, x11, 4
			blt x11, x13 .jLoop
			nop
				
			.jEnd:
			nop
		
		add x7, x7, x8	
		lw x12, 0(x7) ##temp store ax[i]
		sw x9, 0(x7) ##store temp_min at ax[i]
		add x7, x7, x14
		sw x12, 0(x7) ##store ax[i] at ax[j]

		addi x8, x8, 4
	blt x8, x15, .iLoop
	nop

	addi x7, x7, 16 
	lw x28, 0(x7)  ##store median value into register
		
	ret
	nop

copyArray: ##copy of array for quicksort alg
	##copy array to not alter original
	addi x7, x0, 36
	addi x9, x0, 0

.copyLoop:
	add x8, x19, x9
	lw x11, 0(x8)
	add x8, x8, x7
	sw x11, 0(x8)
	addi x9, x9, 4
	blt x9, x7, .copyLoop
	nop
	
	ret
	nop

updatePixel: ##replace middle pixel with median value
	sll x28, x28, x17
	addi x17, x17, 3
	or x18, x18, x28
	
	ret
	nop
	
writePixel: ##write median values to memory at end of word
	sll x7, x28, x17 ##1 or 2 lsb of median value at end of word
	or x18, x18, x7 ##complete middle word median values
	addi x8, x21, -52 ##point to median value memory location
	sw x18, 0(x8) ##store complete median word
	
	addi x18, x0, 0
	addi x9, x0, 3
	andi x8, x23, 3 
	srl x28, x28, x8 ##1 or 2 msb of median value
	or x18, x18, x28 ##create new median word
	sub x17, x9, x8 ##set median word shift value
	
	ret
	nop
	


