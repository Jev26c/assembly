.data
format: .asciz "%[^\n]s"
string: .asciz "%s\n"
string2: .asciz "%d\n"
stringtest: .asciz "AAABBBCCCDDDD"

.global main

main:
	push 	%rbp 				#store basepointer on the stack
	movq	%rsp,%rbp			#stack pointer is the basepointer now
	subq 	$8,%rsp 			#allocate space on the stack for a local variable
	movq	$256, %rdi 			#set the number of bytes to allocate to 256 
	call 	malloc 				#allocate bytes
	movq 	%rax, -8(%rbp)		#store address of allocated bytes in %rax
	movq	$0,%rax				#set %rax to 0 for scanf
	movq 	$format,%rdi 		#move format string in %rdi
	movq 	-8(%rbp),%rsi 		#move the address of the local variable in %rsi
	call 	scanf				#call scanf
	movq 	-8(%rbp), %rdi 	
	#movq	$stringtest, %rdi
	call 	rle
	
	movq 	%rax, %r15
	movq	%rax, %rsi
	movq 	$string, %rdi
	movq 	$0, %rax
	call 	printf
	movq 	%r15, %rdi
	call rld
	movq	%rax, %rsi
	movq 	$string, %rdi
	movq 	$0, %rax
	call 	printf
	movq 	%rbp, %rsp 			#restore stackpointer
	popq 	%rbp				#pop basepointer

	ret

#get string
#count letters and compress
#return string through %rax
rle: 	
	push 	%rbp 						#store basepointer on the stack
	movq	%rsp,%rbp					#stack pointer is the basepointer now
	cmpb 	$0, (%rdi)					#if string is empty then jump to end of function
	je		rlend
	push 	%rdi
	movq 	$3072, %rdi 				#allocate 1024 bytes since the bmp will be 32x32*3
	movq	$1, %rsi 					#size of a byte = 0;
	call 	calloc
	movq	$0, %r12
	
	popq 	%rdi
	movb 	(%rdi),%r12b				#mov first character in to %r12
	movb 	$1, %r13b
	movq	$0, %r14					#set counter to 0
	encode:
		cmpb 	$0, (%rdi)				#check for if the end of the string has been reached
		je	rlend
		incq 	%rdi

		cmpb	(%rdi), %r12b
		jne 	diff
		incb	%r13b
		jmp 	encode
		diff:
			movb 	%r13b, (%rax, %r14) 	# store count
			incq 	%r14	
			movb 	%r12b,(%rax, %r14)		#store character
			incq 	%r14	
			movb 	(%rdi),%r12b			
			movb 	$1, %r13b				#reset counter
			jmp 	encode

	rlend:
	movq 	%rbp, %rsp 					#restore stackpointer
	popq 	%rbp						#pop basepointer
	ret

#decompresses run length encoded strings
#only accepts null termniated strings in %rdi, returns the array in %rax
rld:
	push 	%rbp 						#store basepointer on the stack
	movq	%rsp,%rbp					#stack pointer is the basepointer now

	movq 	$0, %r12 					#set counter to 0
	movq	$0, %r13        			#set iterator to 0

	count: 
		cmpb 	$0,(%rdi,%r13)				#check if the end of the string has been reached	
		je countend
		movb 	(%rdi,%r13),%al 			#store number
		cbtw
		cwtl
		cltq
		addq 	%rax, %r12 					#add to counter
		addq	$2, %r13 					#add 2 to iterator
		jmp count 

	countend:
	cmpq 	$0, %r12 					#compare %r12 = 0
	je rldend
	pushq	%rdi 						#store the encoded string in the stack
	movq 	%r12, %rdi 					#move length in to %rdi
	movq 	  $1, %rsi 					#we want an array of bytes, so size = 1
	call 	calloc						#allocate buffer
	popq 	%rdi 						#pop string of the stack
	pushq 	%rax						#store array on the stack
	movb	(%rdi),%al					#move number in %al
	cbtw
	cwtl
	cltq
	movq	%rax, %r14					#store number in %14	
	popq	%rax
	incq	%rdi						#increment pointer
	movq	$0, %r15					#set counter to 0			
	movq 	$0, %rsi 					#set counter 0
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
			pushq 	%rax						#store array on the stack
			movb	(%rdi),%al					#move number in %al
			cbtw
			cwtl
			cltq
			movq	%rax, %r14					#store number in %14	
			popq	%rax
			incq	%rdi						#increment pointer
			movq	$0, %r15					#set counter to 0
			jmp dloop
	rldend:
	movq 	%rbp, %rsp 					#restore stackpointer
	popq 	%rbp						#pop basepointer

	ret


# takes 5 arguments x, y, x (ax) and y (ay) of the 2d array and bytes per pixel
#this routine maps a 2d array on to a 1d array, value is returned in %rax
loc:
	push 	%rbp 			#store basepointer on the stack
	movq	%rsp,%rbp		#stack pointer is the basepointer now

	cmpq	%rdx, %rdi		#compare x, to ax
	jae locend
	cmpq	%rcx, %rsi		#compate y, to ay
	jae locend

	movq %rsi,%rax			#pixel = (y*ax*bpp) + x*bpp;
	mulq %rdx
	mulq %r8
	push %rax				#store %value in the stack
	movq %rdi, %rax
	mulq %r8
	popq %r12				#pop value from stack
	addq %r12, %rax
	locend:
	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer
	ret

generatekey: # function to generate a the key/white noise
	push 	%rbp 			#store basepointer on the stack
	movq	%rsp,%rbp		#stack pointer is the basepointer now


	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer
	ret
