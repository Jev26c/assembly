.data
errormsg:.asciz "Failed to read file, or file doesn't exist\n"
wmode:	.asciz "w"
rmode: .asciz "r"
string: .asciz "%s\n"
ass: .asciz "Reading Dilbert strips or encoding Elbonian messages are not good excuses for failing the CSE1400 final exam."
instructions: .asciz "-e filename message to encode\n-d filename to decode\n-c filename message to encode for the assigment\n-i to get this information\n"
na: .asciz "not enough arguments \n"
.global main

main:
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	cmpq 	$1, %rdi 							#see if there are any command line args
	je 		inst

	addq 	$8,%rsi 							#get next element in array
	movq	(%rsi),%rax
	movq	$1,%r12
	cmpb	$101,(%rax,%r12)					#-e
	je 		enc
	cmpb	$100,(%rax,%r12)					#-d
	je 		denc
	cmpb	$99,(%rax,%r12)						#-c
	je 		cse
    cmpb	$105,(%rax,%r12)					#-i
	je 		inst
	jmp end

	inst:
		movq	$instructions,%rdi
		movq	$0, %rax
		call printf	
		jmp end
	enc:										#encryption
		cmpq 	$4, %rdi
		jl 		nea
		addq 	$8,%rsi
		movq	(%rsi),%rax
		pushq 	%rax
		addq 	$8,%rsi
		movq	(%rsi),%rsi
		popq	%rdi
		call 	encrypt
		jmp 	end
	denc:										#decryption
		cmpq 	$3, %rdi
		jl 		nea
		addq 	$8,%rsi
		movq	(%rsi),%rdi
		call 	decrypt
		jmp 	end
	cse:										#assigment
		cmpq 	$3, %rdi
		jl		nea 
		addq 	$8,%rsi
		movq	(%rsi),%rdi
		movq	$ass, %rsi
		call 	encrypt
		jmp 	end

	nea:										#not enough arguments
		movq	$na,%rdi
		movq	$0, %rax
		call 	printf	
		jmp 	end
	end:

	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer

	ret

encrypt:										#only needs filename(%rdi) and the string(%rsi)
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	pushq	%rdi 								#store filename on da stek
	movq	%rsi,%rdi
	call 	rle
	pushq	%rax
	movq 	$3072, %rdi 						#allocate 3072 bytes since the bmp will be 32x32*3
	movq	$1, %rsi 							#size of a byte = 1;
	call 	calloc
	movq 	%rax, %r12 							#store arraty in %r12
	movq	$0,	%r13 							#set counter to 0;

	movb	$8,(%r12,%r13)
	incq	%r13
	movb	$67,(%r12,%r13) 					#store C
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$83,(%r12,%r13) 					#store S
	incq	%r13
	movb	$2,(%r12,%r13)
	incq	%r13
	movb	$69,(%r12,%r13) 					#store E
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$49,(%r12,%r13) 					#store '1'
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$52,(%r12,%r13) 					#store '1'
	incq	%r13
	movb	$8,(%r12,%r13)
	incq	%r13
	movb	$48,(%r12,%r13) 					#store '1'
	incq	%r13

	popq	%r14								#retrieve already encoded string
	movq	$0, %r15							# set counter to 0
	apploop:
		cmpq 	$3042, %r13
		je 		app_end
		movb 	(%r14,%r15), %dil
		cmpb 	$0, %dil
		je 		app_end
		movb	%dil, (%r12,%r13)
		incq 	%r13
		incq	%r15
		jmp 	apploop

	app_end:

	movb	$8,(%r12,%r13)
	incq	%r13
	movb	$67,(%r12,%r13) 					#store C
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$83,(%r12,%r13) 					#store S
	incq	%r13
	movb	$2,(%r12,%r13)
	incq	%r13
	movb	$69,(%r12,%r13) 					#store E
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$49,(%r12,%r13) 					#store '1'
	incq	%r13
	movb	$4,(%r12,%r13)
	incq	%r13
	movb	$52,(%r12,%r13) 					#store '4'
	incq	%r13
	movb	$8,(%r12,%r13)
	incq	%r13
	movb	$48,(%r12,%r13) 					#store '0'
	
	pushq	%r12
	call 	generatekey							#generate the image
	movq	%rax, %rsi
	popq 	%rdi
	call 	xordata 							#xor string with the white noise pattern
	movq	%rax,%rdi 						
	call 	generatebitmap						#now make a bitmap out of it
	movq	%rax,%rsi
	popq	%rdi
	call 	writetofile							#store it in an actual file
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

decrypt:										#only needs the filename(%rdi)
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	call 	readfile      						#readfile
	cmpq	$-1,%rax
	je 		de_end
	movq	%rax,%rdi 
	call 	getimage       						#extract the image from  the bmp
	pushq	%rax  								#store the pointer to the image on the stack
	call 	generatekey    						#generate the white noise pattern
	movq	%rax, %rdi     	
	popq 	%rsi
	call 	xordata   							#xor the image data with the white noise
	movq	%rax,%rdi
	call 	removetrails						#removetrails
	movq	%rax,%rdi
	call 	rld 								#decode the message 
	movq	%rax, %rsi 							#print the decoded message 1337 h4x0r moment
	movq	$string,%rdi 
	movq	$0, %rax
	call printf 
	de_end:
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

removetrails: 									#removes trails from the message takes 1 agument the string (%rdi)
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	pushq	%rdi 								#store pointer to the string on the stack 
	movq 	$3072, %rdi 						#allocate 3072 bytes since the bmp will be 32x32*3, but the string is smaller than 3072
	movq	$1, %rsi 							#size of a byte = 1;
	call 	calloc
	movq	%rax, %r12 							#store pointer in %r12
	popq	%r13								#store string in %r13
	movq	$12, %r14 							#set counter to 12, so it skips the first 12 chars , the lead in rle
	movq	$0, %r15							#set counter to 0

	rloop:
		cmpq 	$3060, %r14						#the message is supposed to end at 3060, because the last 12 bytes are supposed to be trail bytes
		je 		trailend
		movb 	(%r13,%r14), %al
		movb 	%al,(%r12,%r15)
		incq	%r14
		incq	%r15
												#detecting the trail, this really could've been it's own sub routine 
		cmpb	$8, (%r13,%r14)				 	#see if the char equals 8, if it does look wether or not the trail has been reached, recognizable by 8C4S2E414480
		je 		t1
		jmp 	rloop

		t1:	
		movq %r14, %rdi
		incq %rdi
		cmpb	$67, (%r13,%rdi)				#is it C?	
		je 		t2
		jmp 	rloop

		t2:
		incq %rdi
		cmpb	$4, (%r13,%rdi)					#is it 4?	
		je 		t3
		jmp 	rloop

		t3:
		incq %rdi
		cmpb	$83, (%r13,%rdi)				#is it S?	
		je 		t4
		jmp 	rloop

		t4:
		incq %rdi
		cmpb	$2, (%r13,%rdi)					#is it 2?	
		je 		t5
		jmp 	rloop
		t5:
		incq %rdi
		cmpb	$69, (%r13,%rdi)				#is it E?	
		je 		t6
		jmp 	rloop
		t6:
		incq %rdi
		cmpb	$4, (%r13,%rdi)					#is it 4?	
		je 		t7
		jmp 	rloop
		t7:
				incq %rdi
		cmpb	$49, (%r13,%rdi)				#is it '1'?	
		je 		t8
		jmp 	rloop
		t8:
				incq %rdi
		cmpb	$4, (%r13,%rdi)					#is it 4?	
		je 		t9
		jmp 	rloop
		t9:
		incq %rdi
		cmpb	$52, (%r13,%rdi)				#is it '4'?	
		je 		t10
		jmp 	rloop
		t10:
		incq %rdi
		cmpb	$8, (%r13,%rdi)					#is it 8?	
		je 		t11
		jmp 	rloop
		t11:
		incq %rdi
		cmpb	$48, (%r13,%rdi)				#is it '0'?	
		je 		trailend
		jmp 	rloop

	trailend:
	movq	%r12, %rax
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret
												#get string
												#count letters and compress
												#return string through %rax
rle: 	
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	cmpb 	$0, (%rdi)							#if string is empty then jump to end of function
	je		rlend
	push 	%rdi
	movq 	$3072, %rdi 						#allocate 3072 bytes since the bmp will be 32x32*3
	movq	$1, %rsi 							#size of a byte = 1;
	call 	calloc
	movq	$0, %r12
	
	popq 	%rdi
	movb 	(%rdi),%r12b						#mov first character in to %r12
	movb 	$1, %r13b
	movq	$0, %r14							#set counter to 0
	encode:
		cmpb 	$0, (%rdi)						#check for if the end of the string has been reached
		je	rlend
		incq 	%rdi

		cmpb	(%rdi), %r12b
		jne 	diff
		incb	%r13b
		jmp 	encode
		diff:
			movb 	%r13b, (%rax, %r14) 		# store count
			incq 	%r14	
			movb 	%r12b,(%rax, %r14)			#store character
			incq 	%r14	
			movb 	(%rdi),%r12b			
			movb 	$1, %r13b					#reset counter
			jmp 	encode

	rlend:
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

												#decompresses run length encoded strings
												#only accepts null termniated strings in %rdi, returns the array in %rax
rld:
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now

	movq 	$0, %r12 							#set counter to 0
	movq	$0, %r13        					#set iterator to 0

	count: 
		cmpb 	$0,(%rdi,%r13)					#check if the end of the string has been reached	
		je countend
		movb 	(%rdi,%r13),%al 				#store number
		cbtw
		cwtl
		cltq
		addq 	%rax, %r12 						#add to counter
		addq	$2, %r13 						#add 2 to iterator
		jmp count 

	countend:
		cmpq 	$0, %r12 						#compare %r12 = 0
		je rldend
		pushq	%rdi 							#store the encoded string in the stack
		movq 	%r12, %rdi 						#move length in to %rdi
		movq 	  $1, %rsi 						#we want an array of bytes, so size = 1
		call 	calloc							#allocate buffer
		popq 	%rdi 							#pop string of the stack
		pushq 	%rax							#store array on the stack
		movb	(%rdi),%al						#move number in %al
		cbtw
		cwtl
		cltq
		movq	%rax, %r14						#store number in %14	
		popq	%rax
		incq	%rdi							#increment pointer
		movq	$0, %r15						#set counter to 0			
		movq 	$0, %rsi 						#set counter 0
		dloop:
			cmpq %r14,%r15
			je dloopend
			movb (%rdi), %r13b
			movb %r13b, (%rax, %rsi)
			incq %r15
			incq %rsi
			jmp dloop

			dloopend:
				incq 	%rdi
				cmpb	$0, (%rdi)
				je rldend  
				pushq 	%rax					#store array on the stack
				movb	(%rdi),%al				#move number in %al
				cbtw
				cwtl
				cltq
				movq	%rax, %r14				#store number in %14	
				popq	%rax
				incq	%rdi					#increment pointer
				movq	$0, %r15				#set counter to 0
				jmp dloop
	rldend:
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer

	ret

												#takes 5 arguments x, y, x (ax) and y (ay) of the 2d array and bytes per pixel
												#(ay) is a bit useless as this subroutine doesn't do bound checking
												#this routine maps a 2d array on to a 1d array, value is returned in %rax
loc:
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now

	cmpq	%rdx, %rdi							#compare x, to ax
	jae locend
	cmpq	%rcx, %rsi							#compate y, to ay
	jae locend

	movq %rsi,%rax								#pixel = (y*ax*bpp) + x*bpp;
	mulq %rdx
	mulq %r8
	push %rax									#store %value in the stack
	movq %rdi, %rax
	mulq %r8
	popq %r12									#pop value from stack
	addq %r12, %rax

	locend:
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret


generatekey: 									# function to generate a the key/white noise, doesn't accept any arguments
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	movq 	$3072, %rdi 						#allocate 3072 bytes since the image will be 32x32*3
	movq	$1, %rsi 							#size of a byte = 0;
	call 	calloc
	movq	%rax, %r14 							#store the empty array in %r14
												#8W,8B,4W,4B,2W,3B,2W,1R
	movq 	$0, %r13 							#i know i could do this more eficiently by writing sun
												#set color to white
	movb 	$255, %dil
	movb 	$255, %sil
	movb 	$255, %dl
	xloop:										#loop over x coords
		cmpq 	$32, %r13
		je 		xend

		movq    $0, %r15
		yloop:									#loop over ycoords to set white pixels
				cmpq 	$32, %r15
				je 		yend
												#i could use stack variables here, but why bother
				pushq 	%rdi
				pushq 	%rsi
				pushq	%rdx

				movq 	%r13,%rdi
				movq 	%r15,%rsi 
				movq	$32,%rdx
				movq	$32,%rcx
				movq	$3, %r8
				call loc
				movq %rax, %r12

				popq %rdx
				popq %rsi
				popq %rdi 
				#set pixels
				movb %dil,(%r14,%r12)
				incq %r12
				movb %sil,(%r14,%r12)
				incq %r12
				movb %dl,(%r14,%r12)

				incq %r15
			jmp yloop
		yend:	
		
    	#swap colors
    	cmpq	$7, %r13
    	je 		toblack
    	cmpq 	$15, %r13
    	je 		towhite
    	cmpq 	$19, %r13
    	je 		toblack
    	cmpq 	$23, %r13
    	je 		towhite
    	cmpq 	$25, %r13
    	je 		toblack
    	cmpq 	$28, %r13
    	je 		towhite
    	cmpq 	$30, %r13
    	je 		tored
    	incq	%r13
    	jmp xloop

    	towhite:
    		movb 	$255, %dil
			movb 	$255, %sil
			movb 	$255, %dl
			incq	%r13
    		jmp xloop
    	#skips would be more eficient
    	toblack:
    		movb 	$0, %dil
			movb 	$0, %sil
			movb 	$0, %dl
			incq	%r13
    		jmp xloop
    	tored:
    		movb 	$0, %dil
			movb 	$0, %sil
			movb 	$255, %dl
			incq	%r13
			jmp xloop

	xend:
	movq	%r14, %rax
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

generatebitmap:									# function to generate a bitmap, takes 1 argument: image data of a 32x32 image
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	pushq 	%rdi 								#store pointer to image ata on the stack
	movq 	$3126, %rdi 						#allocate 3072 bytes since the bmp will be 32x32*3 + 14 + 40
	movq	$1, %rsi 							#size of a byte = 0;
	call 	calloc
	movq	%rax, %r12 							#store the empty array in %r12
	movq	$0, %r13 							#set counter to 0

												#i could not hardcode all of this and write a subroutine 
												#that converts 32/64 bit values in to 4 bytes, but copy pasting is easier

												#generate headers, merge them with the image data 
												#2 bytes with B M 
												#4 bytes(dword) bitmap size
												#2 bytes reserved
												#2 bytes reserved
												#4 bytes(dword) offset to img data, should 14+40
	movq	$66, (%r12,%r13) 					#B  
	incq 	%r13
	movq	$77, (%r12,%r13)					#M 
	incq 	%r13
	movq	$3126,%rax							#Store the bitmap size 
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3126,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3126,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3126,%rax	
	shrq	$24, %rax	
	movb 	%al, (%r12, %r13)
	addq	$5, %r13 							#skip the reserved bytes

	movq	$54,%rax							#Store the offset (14+40 = 54)
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$54,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$54,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$54,%rax
	shrq	$24, %rax		
	movb 	%al, (%r12, %r13)
	incq 	%r13

												#https://www.fileformat.info/format/bmp/egff.htm
												#4 DWORD Size;            /* Size of this header in bytes */ = 40
												#4 LONG  Width;           /* Image width in pixels */ = 32
												#4 LONG  Height;          /* Image height in pixels */ = 32
												#2 WORD  Planes;          /* Number of color planes */ = 1
												#2 WORD  BitsPerPixel;    /* Number of bits per pixel */ = 24
												#4 DWORD Compression;     /* Compression methods used */ = 0
												#4 DWORD SizeOfBitmap;    /* Size of bitmap in bytes */ = 3072
												#4 LONG  HorzResolution;  /* Horizontal resolution in pixels per meter */ =  2835
												#4 LONG  VertResolution;  /* Vertical resolution in pixels per meter */ =  2835
												#4 DWORD ColorsUsed;      /* Number of colors in the image */ = 0
												#4 DWORD ColorsImportant; /* Minimum number of important colors */ = 0

	movq	$40,%rax							#Store the size of the header
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$40,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$40,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$40,%rax	
	shrq	$24, %rax	
	movb 	%al, (%r12, %r13)
	incq 	%r13

	movq	$32,%rax							#Store the size of the header
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax		
	shrq	$24, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13

	movq	$32,%rax							#Store the height
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$32,%rax	
	shrq	$24, %rax	
	movb 	%al, (%r12, %r13)
	incq 	%r13

	movb 	$1, (%r12, %r13) 					#store color planes
	incq 	%r13
	movb 	$0, (%r12, %r13)
	incq 	%r13

	movb 	$24, (%r12, %r13) 					#store bpp
	incq 	%r13	
	movb 	$0, (%r12, %r13)
	addq 	$5,%r13 							#skip compression method, since the eveything is 0 already

	movq	$3072,%rax							#Store the size of the pixel data

	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3072,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3072,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$3072,%rax	
	shrq	$24, %rax	
	movb 	%al, (%r12, %r13)
	incq 	%r13

	movq	$2835,%rax							#Store the horizontal ppm
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$24, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13

	movq	$2835,%rax							#Store the vertical ppm
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$8, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$16, %rax
	movb 	%al, (%r12, %r13)
	incq 	%r13
	movq	$2835,%rax		
	shrq	$24, %rax
	movb 	%al, (%r12, %r13)
	addq	$9, %r13 
												#now   	add the image data here
	popq 	%rdi 								#retrieve the pointer to the image from the stack
	movq	$0, %r14							#set counter to 0
	merge:										#merge pixel data with bmp
	cmpq	$3126,%r13
	je mend

	movb	(%rdi, %r14), %al
	movb	%al, (%r12, %r13)
	incq 	%r13
	incq	%r14
	movb	(%rdi, %r14), %al
	movb	%al, (%r12, %r13)
	incq 	%r13
	incq	%r14
	movb	(%rdi, %r14), %al
	movb	%al, (%r12, %r13)
	incq 	%r13
	incq	%r14
	jmp merge
	mend:
	movq	%r12, %rax							#return the generated bmp
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

getimage:										#takes the image data out of the bmp, takes 1 arg, the bmp file
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
												#allocate empty array
												#read the offset from the headers
												#add offset to counter
												#extract image from bmp
	pushq %rdi
	movq 	$3072, %rdi 						#allocate 3072 bytes since the xorred image will be 32x32*3
	movq	$1, %rsi 							#size of a byte = 0;
	call 	calloc
	movq	%rax, %r12 							#store pointer in %r12
	popq	%r13  								#get ponter to the bmp back
	movq	$0, %r14							#set couter to 0
	addq	$54, %r13
	getloop:
		cmpq 	$3072,%r14
		je 		gend
		movb 	(%r13,%r14), %dil
		movb 	%dil, (%r12,%r14)

		incq	%r14
		jmp 	getloop

	gend:
	movq	%r12,%rax
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

xordata:										# function that xors data with the white noise image, returns an array of 3072 bytes in %rax
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	movq	%rdi, %r13

	movq	%rsi, %r14
	movq 	$3072, %rdi 						#allocate 3072 bytes since the xorred image will be 32x32*3
	movq	$1, %rsi 							#size of a byte = 0;
	call 	calloc
	movq	%rax, %r12
	movq	$0, %r15 
	xorloop:								
		cmpq $3072, %r15
		je 	xorend
		movb 	(%r13,%r15), %dil
		movb 	(%r14,%r15), %sil
		xorb 	%dil,%sil
		movb 	%sil, (%r12,%r15)
		incq %r15
		jmp xorloop

	xorend:
	movq 	%r12, %rax
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

writetofile:									#writes to file (generates one if it doesn't exist), takes 2 arguments a file name (%rdi) and the bmp file (%rsi)
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	pushq	%rsi
	movq	$wmode, %rsi 
	call 	fopen
	popq	%rdi
	movq	$1, %rsi
	movq 	$3126, %rdx
	movq	%rax, %rcx
	pushq	%rax
	call 	fwrite								#set up args for fwrite and call fwrite
	popq	%rdi
	call 	fclose
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret

readfile:										#reads bmp file, returns bmpimage, if the file exists
	push 	%rbp 								#store basepointer on the stack
	movq	%rsp,%rbp							#stack pointer is the basepointer now
	movq	$rmode, %rsi 
	call 	fopen	

	cmpq	$0, %rax
	je 		rerror

	pushq 	%rax
	movq 	$3126, %rdi 						#3126 bytes for the bmp
	movq	$1, %rsi 							#size of a byte = 1;
	call 	calloc
	movq	%rax, %r12

	movq    %r12, %rdi
	movq	$1, %rsi
	movq 	$3126, %rdx
	popq	%rcx
	pushq 	%rcx						
	call 	fread								#set up everything to read a file
	popq	%rdi
	call 	fclose

	jmp 	rsucces
	rerror:
	movq	$errormsg, %rdi
	movq	$0,%rax
	call 	printf
	movq	$-1,%rax
	jmp 	rend

	rsucces:
	movq	%r12, %rax
	rend:
	movq 	%rbp, %rsp 							#restore stackpointer
	popq 	%rbp								#pop basepointer
	ret
