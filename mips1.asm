.data
	#variables used in program
	invalidMessage: .asciiz "NaN"
	string: .space 1001
	tooLarge: .asciiz "too large"


.text

main:
	
 	#take in user input
 	li $v0, 8
 	la $a0, string #load byte space into address
 	li $a1, 1001 # allot the byte space for string
 	syscall	
	
	la $s0, string	#created unchanging reference to string address
	
	addi $a2, $zero, 0	#initiatizing start argument to be passed to subprogram_2
	addi $a3, $zero, 0	#initiatizing end argument to be passed to subprogram_2	
	
	

	loop4:
		#Loops input for substrings
		
		#store address of first ptr in $a2
		#move $a3 by 1 until a comma is reached
		add $t6, $s0, $a3
		lb $t7, 0($t6)		#retrieve char at $a3	
		
		beq $t7, ',', convert 	#go to convert when $a3 points to ','
		beq $t7, 0, convert 	#go to convert when $a3 points to NUL == end of string
		beq $t7, 10, convert 	#go to convert when $a3 points to newLine
		j next	
			
		convert:
			jal subprogram_2	#calls the subprogram_2 for conversion
			jal subprogram_3 	#calls subprogram_3 for output		
			j resetStart		#Program worked so go to next
	
		invalid:
			li $v0, 4
			la $a0, invalidMessage # print out invalid message
			syscall
			j resetStart

		largeString:
			#prints out too large string
			li $v0, 4
			la $a0, tooLarge
			syscall
		
		resetStart:
			addi $a2, $a3, 1	#set the start pointer to the end point
			add $t6, $s0, $a3
			lb $t7, 0($t6)		#retrieve char at $a3					
			beq $t7, 0, exit 	#go to exit when the end of the string is reached
			beq $t7, 10, exit 	#go to exit when the end of the string is reached
			
	
			addi $a0, $zero, 44 		#print comma
			li $v0, 11	
			syscall 
															
		
		next: 
			addi $a3, $a3, 1	#increment end pointer		
			j loop4
		
	exit:	
		li $v0, 10
		syscall
			
subprogram_1:
	#Converts hexadecimal char in argument, $a1 and returns its decimal value in $v1
	addi $t0, $a1, 0	#stores value of parameter in temp 
	
	addi $t1, $zero, 87	#base for 'a' to 'f'
	bgt $t0, 'f', invalid 	#if char is greater than 'f' go to invalid
	bge $t0, 'a', return	#if char is greater than or equal to 'a' go to return
	
	addi $t1, $zero, 55 	#base for 'A' to 'F'
	bgt $t0, 'F', invalid 	#if char is greater than 'F' invalid
	bge $t0, 'A', return	#if char is greater than or equal to 'A' go to return
	
	addi $t1, $zero, 48 	#base for '0' to '9'
	bgt $t0, '9', invalid 	#if char is greater than '9' invalid
	bge $t0, '0', return	#if char is greater than or equal to '0' return 
	
	j invalid 		#if less than zero 
	return:
		sub $v1, $t0, $t1 #returns dec value of char 	
		jr $ra #returning to original code

subprogram_2:
	#converts a hexadecimal string into its decimal value
	#arguments $a2 and $a3 represents the index location for start and end program
	#the result is returned via the stack
	addi $t2, $a2, 0	#copies the argument start index into $t2
	addi $t3, $a3, 0	#copies the argument end index into $t3
	addi $t5, $zero, 0	#initialize result register to zero, this will hold final answer
			
	sw $ra, 0($sp)		#store the location of where jal was called to be retrieved later
	
	loop5:
		#Checks for leading space or tab
		
		add $t6, $s0, $t2	#offset the start of the string
		lb $t7, 0($t6)		#gets char from string
		beq $t7, 32, continue1	#check for space
		beq $t7, 9, continue1	#check for tab		
		beq $t2, $t3, invalid	#Occurs when all chars before the comma is a space or tab
		addi $t3, $t3, -1	#decrement $a3 so that it will not point to the comma	
		j loop6
		
		continue1:
			addi $t2, $t2, 1
			j loop5	
	
	loop6:
		#checks for lagging space or tab
		add $t6, $s0, $t3	#offset the start of the string
		lb $t7, 0($t6)		#gets char from string
		
		beq $t7, 32, continue2	#check for space
		beq $t7, 9, continue2	#check for tab	
		
		sub $t8, $t3, $t2	#CHECKING SIZE OF SUBSTRING
		
		j loop 
		
		continue2:
			addi $t3, $t3, -1 
			j loop6
		
	#loop to get each char in string
	loop: 	
		add $t4, $s0, $t2	#offset the start of the string
		lb $a1, 0($t4)		#gets char from string
		jal subprogram_1 	#call subprogram 1
		sll $t5, $t5, 4		
		or $t5, $t5, $v1	#add returned value from subprogram_1 in $t5
		beq $t2, $t3, return2	#test if the start index register is now equal to the end 
		addi $t2, $t2, 1	#increment $t2 which is the counter
		j loop
	return2:
		bgt $t8, 7, largeString	#substring is too large
		lw $ra, 0($sp)	#retrieves the location of where jal was called from the stack restore it in $ra
		sw $t5, 0($sp)	#stores the final result in the stack at location 0($sp)
		jr $ra
		
subprogram_3:
	
	lw $t0, 0($sp) 	#stores the decimal representation of the value from the stack into $t6
	addi $t1, $zero, 10	#stores the value of 10 
	
	addi $t4, $zero, 0	#counter
	
	

	
	#loop until the quotient of $t0 is zero
	loop2:
		#Stores the decimal value on the stack
		divu $t0, $t1		#divide $t0 by 10
		mfhi $t3		#stores remainder to register
		#sb $t3, 0($t2)		#stores word from $t3 into the stack

		mflo $t0		#stores quotient into $t0  
				
		#addi $t2, $t2, 4	#increment $t2 by 4 
		la $t2, ($sp)	#stores address of sp in temp register
		add $t2, $t4, $t2	#add 
		sb $t3, 0($t2)
		beq $t0, $zero, loop3	#branch when $t0 is zero
		addi $t4, $t4, 1	#increment counter

		
		
		j loop2
		
	loop3:
		#Prints results in reverse
		#$t2 is pointing to the last value stored in the stack
		
		
		lb $a0, 0($t2)	#gets char from stack	
		li $v0, 1	#prints integer
		syscall
		
		beq $t2, $sp, return3	#exit program
		addi $t2, $t2, -1	#decrement by 4
		j loop3
	
		
		
	return3:		
		jr $ra

