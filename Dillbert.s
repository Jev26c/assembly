.data

.global main

main:

	movq $0, %rdi
	call exit

encodeRlE:
	push %rbp		#store old basepointer on the stack
	movq %rsp, %rbp 	#make the stackpointer

	movq %rsp, %rbp		#restore the basepointer
	popq %rbp               #pop %rbp of the stack
	
	
