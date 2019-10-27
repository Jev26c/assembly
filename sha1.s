# made by : sscherpenzeel (4935578) & jchamidullin (4719727)
# gcc -o test -no-pie sha1.s ./sha1_test64.so
# has to be in same folder with sha1_test64.so file

# For reference:
# (%rdi) is h0, 4(%rdi) is h1 etc...'
# w[i] is stored as (%rsi, %r11, 4) or (%rsi, %rax, 4)

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

    movq $16, %rax              # counter to 16 for wordloop

wordloop:

    # Extend the 32-bit words
    # w[i] = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1

    cmp $80, %rax                     
    jge Initialize                  

    movq %rax, %r8                # w[i-3] 
    subq $3, %r8                   
    movl (%rsi, %r8, 4), %r15d

    movq %rax, %r8                # w[i-8]
    subq $8, %r8                   
    movl (%rsi, %r8, 4), %r14d    

    movq %rax, %r8                # w[i-14]
    subq $14, %r8                   
    movl (%rsi, %r8, 4), %r13d

    movq %rax, %r8                # w[i-16]
    subq $16, %r8                   
    movl (%rsi, %r8, 4), %r12d

    xor %r15d, %r14d                  
    xor %r14d, %r13d                 
    xor %r13d, %r12d               

    roll $1, %r12d                  

    movl %r12d, (%rsi, %rax, 4)    

    inc %rax                        
    jmp wordloop                   

Initialize:

    # Initialize hash value for this chunk:

    movl (%rdi), %r15d             # a = h0
    movl %r15d, a

    movl 4(%rdi), %r15d            # b = h1
    movl %r15d, b

    movl 8(%rdi), %r15d            # c = h2
    movl %r15d, c

    movl 12(%rdi), %r15d           # e = h3
    movl %r15d, d

    movl 16(%rdi), %r15d           # e = h4
    movl %r15d, e
    
    movq $0, %rax                  # set counter to 0

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

    # general hashing for all 32 bit words.

    movl a, %r15d               # temp = (a leftrotate 5) + f + e + k + w[i]             
    roll $5, %r15d              
    addl f, %r15d               
    addl e, %r15d               
    addl k, %r15d                
    addl (%rsi, %rax, 4), %r15d 

    movl d, %r14d               # e = d
    movl %r14d, e                

    movl c, %r14d               # d = c
    movl %r14d, d                

    movl b, %r13d               # c = b leftrotate 30
    roll $30, %r13d              
    movl %r13d, c               

    movl a, %r14d               # b = a
    movl %r14d, b                

    movl %r15d, a               # a = temp
    
    inc %rax                    # next word

    jmp mainloop             

loopt20:

    movl c, %r15d      # f = (b and c) or ((not b) and d)         
    and b, %r15d                 
    movl b, %r14d                
    not %r14d                    
    and d, %r14d                 
    or %r15d, %r14d   

    movl %r14d, f             

    movl $0x5A827999, k         
    
    jmp general                

loopt40:

    movl b, %r15d      # f = b xor c xor d           
    xor c, %r15d                 
    xor d, %r15d                 

    movl %r15d, f               

    movl $0x6ED9EBA1, k         

    jmp general                

loopt60:

    movl c, %r15d     # (b and c) or (b and d) or (c and d)           
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

    movl b, %r15d     # f = b xor c xor d             
    xor c, %r15d                 
    xor d, %r15d                 

    movl %r15d, f             

    movl $0xCA62C1D6, k         

    jmp general                

end:

    movl a, %r15d                # h0 = h0 + a
    addl %r15d, (%rdi)              

    movl b, %r15d                # h1 = h1 + b
    addl %r15d, 4(%rdi)          

    movl c, %r15d                # h2 = h2 + c
    addl %r15d, 8(%rdi)          

    movl d, %r15d                # h3 = h3 + d
    addl %r15d, 12(%rdi)         

    movl e, %r15d                # h4 = h4 + e
    addl %r15d, 16(%rdi)         

    movq %rbp, %rsp				
    popq %rbp					

    ret 

