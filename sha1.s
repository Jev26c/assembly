# Made By Rohan Deshamudre(rdeshamudreshi;4831098)
.section .bss
.lcomm h0, 4
.lcomm h1, 4
.lcomm h2, 4
.lcomm h3, 4
.lcomm h4, 4
.lcomm a, 4
.lcomm b, 4
.lcomm c, 4
.lcomm d, 4
.lcomm e, 4

.lcomm m, 4
.lcomm n, 4

.section .text

.global sha1_chunk

sha1_chunk:
    pushq %rbp					#push the base pointer
	movq %rsp,%rbp				#copying the stackpointer to rbp

    movq %rdi, %rbx             # put the address of h0 into RBX

    movl (%rbx), %ecx           #copy h0 into ecx 
    movl %ecx, h0               #and then into the memory variable h0

    movl 4(%rbx), %ecx          #copy h1 into ecx
    movl %ecx, h1               #and then into the memory variable h1

    movl 8(%rbx), %ecx          #copy h2 into ecx
    movl %ecx, h2               #and then into the memory variable h2

    movl 12(%rbx), %ecx         #copy h3 into ecx
    movl %ecx, h3               #and then into the memory variable h3

    movl 16(%rbx), %ecx         #copy h4 into ecx
    movl %ecx, h4               #and then into the memory variable h4

    movq $16, %rax              #set counter to 16 for firstLoop

#Extend the sixteen 32-bit words into eighty 32-bit words
firstLoop:
    cmp $80, %rax                   #if counter is >= 80       
    jge next                        #jump to next

    movq %rax, %rcx                 #copy rax to rcx
    
    subq $3, %rcx                   #take i-3 
    movl (%rsi, %rcx, 4), %r8d      #copy w[i-3] into r8
   
    subq $5, %rcx                   #take i-8
    movl (%rsi, %rcx, 4), %r9d      #copy w[i-8] into r9

    subq $6, %rcx                   #take i-14
    movl (%rsi, %rcx, 4), %r10d     #copy w[i-14] into r10

    subq $2, %rcx                   #take i-16
    movl (%rsi, %rcx, 4), %r11d     #copy w[i-16] into r11

    xor %r8d, %r9d                  #xor r8 with r9
    xor %r9d, %r10d                 #xor result with r10
    xor %r10d, %r11d                #xor result with r11

    roll $1, %r11d                  #rotate r11 to the left by 1 bit

    movl %r11d, (%rsi, %rax, 4)     #copy the result to w[i]

    inc %rax                        #increment the counter
    jmp firstLoop                   #Jump to firstLoop

next:
    movl h0, %ecx               #copy h0 to a
    movl %ecx, a

    movl h1, %ecx               #copy h1 to b 
    movl %ecx, b

    movl h2, %ecx               #copy h2 to c
    movl %ecx, c

    movl h3, %ecx               #copy h3 to d
    movl %ecx, d

    movl h4, %ecx               #copy h4 to e
    movl %ecx, e
    
    movq $0, %rax               #set counter to 0
    jmp mainLoop                #jump mainLoop


continue:
    movl a, %edx                #copy a into temp               
    roll $5, %edx               #rotate temp to the left by 5
    addl m, %edx                #add m to temp
    addl e, %edx                #add e to temp
    addl n, %edx                #add n to temp

    addl (%rsi, %rax, 4), %edx  #add w[i] to temp

    movl d, %ecx                #copy d to e
    movl %ecx, e

    movl c, %ecx                #copy c to d
    movl %ecx, d

    movl b, %r8d                #copy b to r8
    roll $30, %r8d              #rotate to the left by 30
    movl %r8d, c                #and then into c

    movl a, %ecx                #copy a to b
    movl %ecx, b

    movl %edx, a                #copy temp to a
    
    inc %rax                    #increment counter
    # go to for loop 1

mainLoop:

    cmp $80, %rax               #if counter >= 80
    jge end                     #jump end 

    cmp $19, %rax               #if counter <= 19
    jle firstIF                 #jump to firstIF

    cmp $39, %rax               #if counter <= 39
    jle secondIF                #jump to secondIF

    cmp $59, %rax               #if counter <= 59
    jle thirdIF                 #jump to thirdIF

    cmp $79, %rax               #if counter <= 79
    jle forthIF                 #jump to forthIF

firstIF:
    movl c, %r8d                #copy c to r8
    and b, %r8d                 #and b to r8

    movl b, %r9d                #copy b to r9
    not %r9d                    #flip r9
    and d, %r9d                 #and d with r9

    or %r8d, %r9d               #or r8 with r9

    movl %r9d, m                #copy r9 to m

    movl $1518500249, n         #copy 0x5A827999 into n
    
    jmp continue                #jump to continue

secondIF:
    movl b, %r8d                #copy b to r8
    xor c, %r8d                 #xor c with r8
    xor d, %r8d                 #xor d with r8

    movl %r8d, m                #copy result to m

    movl $1859775393, n         #copy 0x6ED9EBA1 into n 

    jmp continue                #jump to continue

thirdIF:
    movl c, %r8d                #copy c to r8
    and b, %r8d                 #and b with r8

    movl d, %r9d                #copy d to r9
    and b, %r9d                 #and b with r9

    movl d, %r10d               #copy d to r10
    and c, %r10d                #and c with r10

    or %r8d, %r9d               #or r8 with r9
    or %r9d, %r10d              #or result with r10

    movl %r10d, m               #copy result to 

    movl $2400959708, n         #copy 0x8F1BBCDC into n

    jmp continue                #jump to continue

forthIF:
    movl b, %r8d                #copy b to r8
    xor c, %r8d                 #xor c with r8
    xor d, %r8d                 #xor d with r8

    movl %r8d, m                #copy result to m

    movl $3395469782, n         #copy 0xCA62C1D6 into n

    jmp continue                #jump to continue

end:
    movl a, %ecx                #Copy a to %ecx for addition
    addl %ecx, h0               #add a to h0    

    movl b, %ecx                #Copy b to %ecx for addition
    addl %ecx, h1               #add b to h01

    movl c, %ecx                #Copy c to %ecx for addition
    addl %ecx, h2               #add c to h2

    movl d, %ecx                #Copy d to %ecx for addition
    addl %ecx, h3               #add d to h3

    movl e, %ecx                #Copy e to %ecx for addition
    addl %ecx, h4               #add e to h4
    
    movl h0, %ecx               #copy h0 back into normal address
    movl %ecx, (%rbx)           #rbx the address of h0

    movl h1, %ecx               #copy h1 back into normal address
    movl %ecx, 4(%rbx)          #4(rbx) the address of h1

    movl h2, %ecx               #copy h2 back into normal address
    movl %ecx, 8(%rbx)          #8(rbx) the address of h2

    movl h3, %ecx               #copy h3 back into normal address
    movl %ecx, 12(%rbx)         #12(rbx) the address of h3

    movl h4, %ecx               #copy h4 back into normal address
    movl %ecx, 16(%rbx)         #16(rbx) the address of h4

    movq %rbp, %rsp				#clear variables from stack
	popq %rbp					#restore base pointer
    ret                         #return back to Sha1 call



