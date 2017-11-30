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
	
	addi $a2, $a2, 0	#initiatizing start argument to be passed to subprogram_2
	addi $a3, $a3, 0	#initiatizing end argument to be passed to subprogram_2	
	
	loop4:
		#Loops input for substrings
		#store address of first ptr in $a2
		#move $a3 by 1 until a comma is reached
		add $t6, $s0, $a3
		lb $t7, 0($t6)		#retrieve char at $a3	

		beq $t7, ',', convert 	#go to convert when $a3 points to ','
		beq $t7, 0, convert 	#go to convert when $a3 points to NUL == end of string
		beq $t7, 10, convert 	#go to convert when $a3 points to newLine

		convert:
			#jal subprogram_2	#calls the subprogram_2 for conversion
			#jal subprogram_3 	#calls subprogram_3 for output		
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
		#jal subprogram_1 	#call subprogram 1
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
