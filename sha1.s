# gcc -o test -no-pie sha1.s ./sha1_test64.so
# has to be in same folder with sha1_test64.so file

#For reference:
#(%rdi) is h0, 4(%rdi) is h1 etc...'
#w[i] is stored as (%rsi, %rdx, 4) or (%rsi, %rax, 4) where %rsi 

.comm a, 4
.comm b, 4
.comm c, 4
.comm d, 4
.comm e, 4
.comm f, 4
.comm k, 4

.global sha1_chunk

sha1_chunk:
    pushq %rbp					
	movq %rsp,%rbp				

    movq $16, %rax              #counter to 16 for wordloop

wordloop:

#Extend the 32-bit words
#w[i] = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1

    cmp $80, %rax                     
    jge Initialize                  

    movq %rax, %rdx                # w[i-3] 
    subq $3, %rdx                   
    movl (%rsi, %rdx, 4), %r15d

    movq %rax, %rdx                # w[i-8]
    subq $8, %rdx                   
    movl (%rsi, %rdx, 4), %r14d    

    movq %rax, %rdx                # w[i-14]
    subq $14, %rdx                   
    movl (%rsi, %rdx, 4), %r13d

    movq %rax, %rdx                # w[i-16]
    subq $16, %rdx                   
    movl (%rsi, %rdx, 4), %r12d

    xor %r15d, %r14d                  
    xor %r14d, %r13d                 
    xor %r13d, %r12d               

    roll $1, %r12d                  

    movl %r12d, (%rsi, %rax, 4)    

    inc %rax                        
    jmp wordloop                   

Initialize:

# Initialize general value for this chunk:

    movl (%rdi), %ecx              #copy h0 to a
    movl %ecx, a

    movl 4(%rdi), %ecx             #copy h1 to b 
    movl %ecx, b

    movl 8(%rdi), %ecx             #copy h2 to c
    movl %ecx, c

    movl 12(%rdi), %ecx            #copy h3 to d
    movl %ecx, d

    movl 16(%rdi), %ecx            #copy h4 to e
    movl %ecx, e
    
    movq $0, %rax                  #set counter to 0

mainloop:

# main loop for hashing every 32 bit word, different method every 20 words stop when it reaches 80.

    cmp $80, %rax               
    jge end                      

    cmp $19, %rax               
    jle loopt20                 

    cmp $39, %rax               
    jle loopt40                 

    cmp $59, %rax               
    jle loopt60                 

    cmp $79, %rax               
    jle loopt80    

general:

    movl a, %edx                #temp = (a leftrotate 5) + f + e + k + w[i]             
    roll $5, %edx               
    addl f, %edx                
    addl e, %edx                
    addl k, %edx                
    addl (%rsi, %rax, 4), %edx  

    movl d, %ecx                #e = d
    movl %ecx, e                

    movl c, %ecx                #d = c
    movl %ecx, d                

    movl b, %r15d               #c = b leftrotate 30
    roll $30, %r15d              
    movl %r15d, c               

    movl a, %ecx                #b = a
    movl %ecx, b                

    movl %edx, a                #a = temp
    
    inc %rax                    

    jmp mainloop             

loopt20:

    #f = (b and c) or ((not b) and d)


    movl c, %r15d               
    and b, %r15d                 
    movl b, %r14d                
    not %r14d                    
    and d, %r14d                 
    or %r15d, %r14d   

    movl %r14d, f             

    movl $0x5A827999, k         
    
    jmp general                

loopt40:

    #f = b xor c xor d 

    movl b, %r15d                
    xor c, %r15d                 
    xor d, %r15d                 

    movl %r15d, f               

    movl $0x6ED9EBA1, k         

    jmp general                

loopt60:
    
    #(b and c) or (b and d) or (c and d)

    movl c, %r15d                
    and b, %r15d                 
    movl d, %r14d                
    and b, %r14d                 
    movl d, %r13d               
    and c, %r13d                
    or %r15d, %r14d               
    or %r14d, %r13d              

    movl %r13d, f

    movl $0x8F1BBCDC, k         

    jmp general                

loopt80:

    #f = b xor c xor d

    movl b, %r15d                
    xor c, %r15d                 
    xor d, %r15d                 

    movl %r15d, f             

    movl $0xCA62C1D6, k         

    jmp general                

end:
    movl a, %ecx                #add a to h0 
    addl %ecx, (%rdi)              

    movl b, %ecx                #add b to h1
    addl %ecx, 4(%rdi)          

    movl c, %ecx                #add c to h2
    addl %ecx, 8(%rdi)          

    movl d, %ecx                #add d to h3
    addl %ecx, 12(%rdi)         

    movl e, %ecx                #add e to h4
    addl %ecx, 16(%rdi)         

    movq %rbp, %rsp				#clear variables from stack
	popq %rbp					#restore base pointer

    ret 

