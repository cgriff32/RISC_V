#x29, x30, x31 row 1 row 2 row 3
#x28 calculated median value
#x27 row counter
#x26 column counter
#x25 byte counter
#x24 array counter
#x22 New image pointer
#x21 Original image pointer
#x20 Image offset (word pointer offset)
#x19 Array pointer
#x18 middle row median values
#x17 x18 shift offset
#x16 new image offset
#x15-x7 temp

#0-4799 Original image (4800 words)
#4800-4817 Array (9 words) Array copy (9 words)
#4818-9617 New image (4800 words)

.Main:
initialLoad:
	nop
	nop
	nop


	addi x21, x0, 0	#(original image malloc (4800 words))
	addi x7, x0, 2000
	addi x7, x7, 2000
	addi x7, x7, 800 
	addi x22, x7, 0 #(Array and Array copy malloc (18 words)
	add x19, x22, x7 #(new image malloc (4800 words))

	addi x9, x0, 0
	addi x10, x0, 80
	jal copyOuterRows
	nop
	jal loadNewWord
	nop
	jal pixelToArray
	nop
	addi x23, x17, 0
	addi x18, x0, 8

	jal pixelToArray
	nop
	jal pixelToArray
	nop

	##Array is full

	jal copyArray #keep array values, compute on copied array
	nop
	jal findMedian  #find median value out of 9
	nop
	sll x7, x28, x18
	or x23, x23, x7
	addi x18, x18, 8

.Loop1:
nop
	addi x7, x0, 36
	bge x24, x7, arrayOverflow ##(Check array overflow (9 >> 0)

	addi x7, x0, 20
	bgt x26, x7, colOverflow ##(Check column overflow (20 >> 0, row + 1))

	addi x7, x0, 4
	beq x25, x7, wordOverflow ##(Check word overflow (4 >> 0, col + 1))
	nop

	jal pixelToArray ##add new bytes to array to find median value
	nop
	jal copyArray 
	nop
	jal findMedian
	nop
	sll x7, x28, x18
	or x23, x23, x7
	addi x18, x18, 8

	addi x7, x0, 32
	nop
	beq x18, x7 writeWord
	nop

j .Loop1
nop

copyOuterRows:
copyFirstRow:
nop
	add x7, x21, x9
	add x8, x22, x9
	addi x9, x9, 4
	lw x11, 0(x7)
	sw x11, 0(x8)

	nop
	nop
	nop
	nop
	nop
	nop
	ble x9, x10 copyFirstRow
	nop
	add x9, x0, x0
	addi x11, x22, -80
	addi x12, x22, 2000
	addi x12, x12, 2000
	addi x12, x12, 720

copyLastRow:
nop
	add x7, x11, x9
	add x8, x12, x9
	lw x13, 0(x7)
	sw x13, 0(x8)

	addi x9, x9, 4
	nop
	blt x9, x10 copyLastRow
	nop
	nop
	nop
ret
nop

loadNewWord:
nop
	add x7, x21, x20
	lw x29, 0(x7)	#load 4 pixels from memory for each row
	lw x30, 80(x7)
	lw x31, 160(x7)

	addi x20, x20, 4 #point to next word
	addi x25, x0, 0 #byte counter (word overflow)
	addi x26, x26, 1 #word counter (col overflow)
ret
nop

pixelToArray: #(Handles adding full pixel stored in register to array for compute)
	nop
	add x8, x19, x24 #array base + offset
	andi x7, x29, 255 #mask lsb 8 bits from row
	nop
	sw x7, 0(x8) #store pixel into array

	andi x7, x30, 255
	andi x17, x30, 255
	nop
	sw x7, 4(x8)

	

	andi x7, x31, 255
	nop
	sw x7, 8(x8)

	#shift next pixel to lsb
	srli x29, x29,8
	srli x30, x30, 8
	srli x31, x31, 8

	
	addi x24, x24, 12 #increment array counter (9 = need rollover)
	addi x25, x25, 1 #byte counter (4 = get next word)	
ret
nop

wordOverflow:
nop
	add x7, x21, x20
	lw x29, 0(x7)	#load 4 pixels from memory for each row
	nop
	lw x30, 80(x7)
	nop
	lw x31, 160(x7)
	nop

	addi x20, x20, 4 #point to next word
	addi x25, x0, 0 #byte counter (word overflow)
	addi x26, x26, 1 #word counter (col overflow)
	
	
	j .Loop1
	nop
	
arrayOverflow: #(after adding 9th pixel to array, move back to base array address)
nop
	addi x24, x0, 0
	nop
j .Loop1
nop
nop
nop
nop
	
colOverflow: ##New row
nop
	sll x7, x28, x18
	or x23, x23, x7
	addi x18, x0, 8

	jal writeWord
	nop

	#addi x16, x16, 40
	#addi x20, x20, 160 #new row base addr (x20 = 80 + 160 (skip ))
	addi x27, x27, 1 #row counter (row overflow)
	addi x26, x0, 0 #reset word counter (col overflow)

	addi x7, x0, 59
	nop
	bge x27, x7 rowOverflow ##(end of image)
	nop

	jal loadNewWord
	nop
	
	addi x24, x0, 0
	addi x26, x0, 0
	
	jal pixelToArray
	nop
	jal pixelToArray
	nop
	jal pixelToArray
	nop

	jal copyArray
	nop
	jal findMedian
	nop
j .Loop1
nop

copyArray: ##copy of array for quicksort alg
nop
	##copy array to not alter original
	addi x7, x0, 36
	addi x9, x0, 0

	.copyLoop:
	nop
		add x8, x19, x9
		lw x11, 0(x8) #get array at index x8

		nop
		nop
		sw x11, 36(x8) #store array at index x8 in x8+9
		addi x9, x9, 4 #inc array pointer
	nop
	blt x9, x7, .copyLoop
	nop
ret
nop

findMedian: ##quicksort median finder
nop
	addi x7, x19, 36 ##array copy base address
	addi x8, x0, 0 ##int i = 0
	addi x11, x0, 0 ##int j = 0
	addi x15, x0, 20 ##check if i < 5
	addi x13, x0, 36 ##check if j < 9

	nop
	.iLoop:
	nop
		add x3, x7, x8 #array copy base addr + i
		lw x9, 0(x3) #temp_min = ax[i]

		addi x11, x8, 4 ## j = i+1
		nop
		nop
		.jLoop:
		nop
			add x3, x7, x11 ##pointer to ax[j]
			lw x10, 0(x3) ##ax[j]
			bgt x9, x10 updateTempMin ##tempmin > ax[j]
			nop
			addi x11, x11, 4
			bge x11, x13 .jEnd
			nop
		j .jLoop
		nop
			updateTempMin:
			addi x9, x10, 0 ##ax[j] to tempmin
			addi x14, x11, 0 ##j index for tempmin value
			addi x11, x11, 4
		blt x11, x13 .jLoop
		nop
		.jEnd:
		nop
		
		add x3, x7, x8	
		lw x12, 0(x3) ##temp store ax[i]
		sw x9, 0(x3) ##store temp_min at ax[i]
		add x3, x7, x14
		sw x12, 0(x3) ##store ax[i] at ax[j]
		addi x8, x8, 4
	nop
	blt x8, x15, .iLoop
	nop

	lw x28, 52(x19)  ##store median value into register
ret
nop
	
writeWord: ##write median values to memory at end of word
nop
	add x7, x22, x16 #image base + offset (write pointer)
	sw x23 80(x7)

	addi x18, x0, 0
	addi x23, x0, 0

	addi x16, x16, 4
ret
nop
	
rowOverflow: ##end of image
nop
	ecall
	nop
j rowOverflow
nop