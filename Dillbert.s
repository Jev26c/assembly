.data
format: .asciz "%[^\n]s"
string: .asciz "%d\n"
string2: .asciz "%d\n"
.global main

main:
	push 	%rbp 			#store basepointer on the stack
	movq	%rsp,%rbp		#stack pointer is the basepointer now
	subq 	$8,%rsp 		#allocate space on the stack for a local variable
	movq	$256, %rdi 		#set the number of bytes to allocate to 256 
	call 	malloc 			#allocate bytes
	movq 	%rax, -8(%rbp)	#store address of allocated bytes in %rax
	movq	$0,%rax			#set %rax to 0 for scanf
	movq 	$format,%rdi 	#move format string in %rdi
	movq 	-8(%rbp),%rsi 	#move the address of the local variable in %rsi
	call 	scanf			#call scanf
	movq 	-8(%rbp), %rdi 	
	call 	rle
	push	%rax
	call 	createimage
	movq 	%rax, %rdx

	movq 	%rax, %rsi
	movq 	$string, %rdi
	movq 	$0, %rax
	call printf

	movq 	%r14, %rsi
	popq 	%rdi
	call 	xorstring

	movq 	%rax, %rsi
	movq 	$string2, %rdi
	movq 	$0, %rax
	call printf
	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer

	ret

rle:
	#get string
	#count letters and compress
	#return string through %rax
	push 	%rbp 			#store basepointer on the stack
	movq	%rsp,%rbp		#stack pointer is the basepointer now
	cmpb 	$0, (%rdi)		#if string is empty then jump to end of function
	je		rlend
	push 	%rdi
	movq 	$1024, %rdi 	#allocate 1024 bytes since the bmp will be 32x32
	movq	$1, %rsi 		#size of a byte = 0;
	call 	calloc
	movq	$0, %r12
	
	popq 	%rdi
	movb 	(%rdi),%r12b		#mov first character in to %r12
	movb 	$1, %r13b
	movq	$0, %r14
	encode:
		cmpb 	$0, (%rdi)
		je		rlend
		incq 	%rdi

		cmpb	(%rdi), %r12b
		jne 	diff
		incb	%r13b
		jmp 	encode
		diff:
		movb 	%r13b, (%rax, %r14)
		incq 	%r14	
		movb 	%r12b,(%rax, %r14)
		incq 	%r14	
		movb 	(%rdi),%r12b
		movb 	$1, %r13b
		jmp 	encode

	rlend:
	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer
	ret


xorstring:
	#key is some white nose pattern
	#key is 8W 8B 4W 4B 2W 3B 2W 1R
	#xor it with the encoded data
	#rdi = string
	#rsi = string length 
	#rdx is bitmap
	movq %rsi, %rbx
	xorloop:
	movb	(%rdi,%r12), %r14b
	movb	(%rdx,%r12), %r15b
	xorb	%r15b, %r14b
	movb	%r15b, (%rdx, %r12)
	incq %r12
	cmpq %r12, %r13
	jne xorloop
	movq %rdx, %rax
	ret
createimage:
	#pixloc = (yloc * bytes_per_row) + (xloc * bytes_per_pixel);
	#8W 8B 4W 4B 2W 3B 2W 1R
	movq 	$3072, %rdi 	#32x32x3 = 3072
	movq 	$1,%rsi 		#byte size
	call 	calloc 			#call calloc
	movq 	$0, %r12 	 	#set offset to 0 for 
	#set 	the values of the bitmap by hand

	#8 white pixels 	(24 bytes)
	imgloop:
	movb	$255,   (%rax,%r12)
	movb	$255,  1(%rax,%r12)
	movb	$255,  2(%rax,%r12)
	movb	$255,  3(%rax,%r12)
	movb	$255,  4(%rax,%r12)
	movb	$255,  5(%rax,%r12)
	movb	$255,  6(%rax,%r12)
	movb	$255,  7(%rax,%r12)
	movb	$255,  8(%rax,%r12)
	movb	$255,  9(%rax,%r12)
	movb	$255, 10(%rax,%r12)
	movb	$255, 11(%rax,%r12)
	movb	$255, 12(%rax,%r12)
	movb	$255, 13(%rax,%r12)
	movb	$255, 14(%rax,%r12)
	movb	$255, 16(%rax,%r12)
	movb	$255, 17(%rax,%r12)
	movb	$255, 18(%rax,%r12)
	movb	$255, 19(%rax,%r12)
	movb	$255, 20(%rax,%r12)
	movb	$255, 21(%rax,%r12)
	movb	$255, 22(%rax,%r12)
	movb	$255, 23(%rax,%r12)

	#4 white pixels (12 bytes)
	movb	$255, 47(%rax,%r12)
	movb	$255, 48(%rax,%r12)
	movb	$255, 49(%rax,%r12)
	movb	$255, 50(%rax,%r12)
	movb	$255, 51(%rax,%r12)
	movb	$255, 52(%rax,%r12)
	movb	$255, 53(%rax,%r12)
	movb	$255, 54(%rax,%r12)
	movb	$255, 55(%rax,%r12)
	movb	$255, 56(%rax,%r12)
	movb	$255, 57(%rax,%r12)
	movb	$255, 58(%rax,%r12)
	movb	$255, 59(%rax,%r12)

	#2 white pixels (6 bytes)
	movb	$255, 71(%rax,%r12)
	movb	$255, 72(%rax,%r12)
	movb	$255, 73(%rax,%r12)
	movb	$255, 74(%rax,%r12)
	movb	$255, 75(%rax,%r12)
	movb	$255, 76(%rax,%r12)
	movb	$255, 77(%rax,%r12)

	#2 white pixels again (6 bytes)
	movb	$255, 86(%rax,%r12)
	movb	$255, 87(%rax,%r12)
	movb	$255, 88(%rax,%r12)
	movb	$255, 89(%rax,%r12)
	movb	$255, 90(%rax,%r12)
	movb	$255, 91(%rax,%r12)
	movb	$255, 92(%rax,%r12)

	#1 red pixel (3 bytes)
	movb	$255, 93(%rax,%r12)

	addq 	$96, %r12

	cmpq 	$0, %r12
	jle 	imgloop
	
	ret

createbitmap:
	#32x32 is bmp size
	ret

rld:
	#decode the string
	ret

loadbitmap:
	ret
