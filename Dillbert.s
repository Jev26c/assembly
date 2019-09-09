
.data
format: .asciz "%[^\n]s"
string: .asciz "%s\n"
string2: .asciz "%d hello \n"
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
	call 	rle
	
	movq 	%rax, %r15
	movq	%rax, %rsi
	movq 	$string, %rdi
	movq 	$0, %rax
	call 	printf
	movq 	%r15, %rdi
	#call rld
	movq $1, %rdi
	movq $1, %rsi
	movq $1, %rdx
	movq $32, %rcx
	movq $3, %r8
	call loc
	movq 	%rbp, %rsp 			#restore stackpointer
	popq 	%rbp				#pop basepointer

	ret

rle: 	
								#get string
								#count letters and compress
								#return string through %rax
	push 	%rbp 				#store basepointer on the stack
	movq	%rsp,%rbp			#stack pointer is the basepointer now
	cmpb 	$0, (%rdi)			#if string is empty then jump to end of function
	je		rlend
	push 	%rdi
	movq 	$3072, %rdi 		#allocate 1024 bytes since the bmp will be 32x32*3
	movq	$1, %rsi 			#size of a byte = 0;
	call 	calloc
	movq	$0, %r12
	
	popq 	%rdi
	movb 	(%rdi),%r12b		#mov first character in to %r12
	movb 	$1, %r13b
	movq	$0, %r14			#set counter to 0
	encode:
		cmpb 	$0, (%rdi)		#check for if the end of the string has been reached
		je		rlend
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
	movb 	$0 ,(%rax, %r14)
	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer
	ret

#incomplete rld routine
rld:
	push 	%rbp 			#store basepointer on the stack
	movq	%rsp,%rbp		#stack pointer is the basepointer now

	movq 	$0, %r12 		#set counter to 0
	movq	$0, %r13        #set iterator to 0

	count: 
	cmpb 	$0,(%rdi)		#check if the end of the string has been reached	
	je end
	movb 	(%rdi,%r13),%al #store number
	cbtw
	cwtl
	cltq
	addq 	%rax, %r12 		#add to counter
	addq	$2, %r13 		#add 2 to iterator

	movq	%rax, %rsi
	movq	$string2, %rdi
	movq	$0, %rax
	call 	printf

	movq 	%rbp, %rsp 		#restore stackpointer
	popq 	%rbp			#pop basepointer

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
