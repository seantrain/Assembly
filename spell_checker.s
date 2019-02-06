
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
dictionaryTokens:	.space 200001	#Maximum number of dictionary words * maximum word size + 1
correctWords:		.space 2049     #Maximum input size + NULL
token:   		.space 4198401	#Maxsize * Maxsize for 2D array



#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
# You can add your code here!  	
#tokenizer for content (input file) 	
    	li   $t0, 0    		#set $t0 to be index value 0 (c_idx)
    	li   $s0, 0   		#set $s0 to be the number of tokens 
    	li   $t2, 0		#set $t2 to be the index value 0 (token_c_idx)
    	lb   $t1, content($t0)	#$t1 = the first char in content
    	li   $t3, 0		#set $t3 to be the number of tokens times * array size
    	li   $t4, 0		#size + the token_c_idx to place char into correct row

NOTNULL:    
    	bnez $t1, IF1  		#while content(c_idx) not null terminator, branch to first IF statement for alphabetical chars
    	j GODIC   		#if content(c_idx) = null, jump to STARTP (start print)

IF1:    			#IF statement for checking if char is alphabetical
    	blt  $t1, 65, ELSE   	# < A(65) ELSE or >= A(65) continue
    	ble  $t1, 90, THEN   	# <= Z(90) THEN or  > Z(90) continue
    	blt  $t1, 97, ELSE   	# < a(97) ELSE or >= a(97) continue
    	ble  $t1, 122, THEN   	# <= z(122) THEN or > z(122) continue
    
ELSE: 
    j IF2			#jump to second IF statement if content(c_idx) is not an alphabetical char
        
THEN:   				 
    	mul  $t3, $s0, 2049   	#$t3 = (token number)*(array size)
    	add  $t4, $t2, $t3	#$t4 = $t2(token_c_idx) + $t3
    	sb   $t1, token($t4)   	#c = token(token_number)(token_c_idx)

    	add  $t0, $t0, 1   	#incrementing c_idx_ by 1
    	add  $t2, $t2, 1   	#incrementing token_c_idx by 1
    	lb   $t1, content($t0)	#set $t1 = content($t1+1) (next char in content)
    
    	j CON			#check next char to see if alphabetical
    	
CON:
    	blt  $t1, 65, RESET   	#<65 reset
    	beq  $t1, 91, RESET   	#91-96 reset
    	beq  $t1, 92, RESET
    	beq  $t1, 93, RESET
    	beq  $t1, 94, RESET
    	beq  $t1, 95, RESET
    	beq  $t1, 96, RESET		
    	bge  $t1, 122, RESET	#>122 reset
    	j THEN
 	
RESET:
    	add  $s0, $s0, 1	#increment number of tokens by 1
    	li   $t2, 0		#set token_c_idx = 0 again
   	j NOTNULL
   	 
IF2:   				#If statements for if char is punctuation
    	beq  $t1, 33, THEN2   	#, = 44 . = 46 ? = 63 ! = 33
    	beq  $t1, 44, THEN2
    	beq  $t1, 46, THEN2
    	beq  $t1, 63, THEN2
    	j IF3			#if not punctuation, go to next IF statement to check for space	

    
THEN2:				#same as before
    	mul  $t3, $s0, 2049   	
    	add  $t4, $t2, $t3		
    	sb   $t1, token($t4)   	
    
    	add  $t0, $t0, 1   	 	
    	add  $t2, $t2, 1   		
    	lb   $t1, content($t0)
    	j CON2			#check if the next char is also punctuation
    
CON2:
    	beq  $t1, 33, THEN2   	#not equal to 33, 44, 46, 63 jump to RESET
    	beq  $t1, 44, THEN2	#otherwise jump to THEN2
    	beq  $t1, 46, THEN2
    	beq  $t1, 63, THEN2
    	j RESET
    
IF3:
    	beq  $t1, 32, THEN3	#IF statement to check if content(c_idx) is a space
    	j GODIC		#if not, jump to start print
THEN3:				#same as before
    	mul  $t3, $s0, 2049   	
    	add  $t4, $t2, $t3		
    	sb   $t1, token($t4)   	
    
    	add  $t0, $t0, 1   	 	
    	add  $t2, $t2, 1   	 	
    	lb   $t1, content($t0)
    	j CON3			#check to see if next char is also a space

CON3:
    	beq  $t1, 32, THEN3	#if equal then jump to THEN3 otherwise jump to reset
    	j RESET


GODIC:				#go to dictionary tokinize section after doing content tokenize
    	j STARTDICTIONARY
    	
#tokenizer for dictionary file
STARTDICTIONARY:
    	li   $t0, 0    		#set $t0 to be index value 0 (c_idx)
    	li   $s1, 0   		#set $s0 to be the number of tokens 
    	li   $t2, 0		#set $t2 to be the index value 0 (token_c_idx)
    	lb   $t1, dictionary($t0)	#$t1 = the first char in content
    	li   $t3, 0		#set $t3 to be the number of token number * word size + 1
    	li   $t4, 0		#size + the token_c_idx to place char into correct row
    	li   $t5, 10		#new line char
NOTNULLD:    
    	bnez $t1, IFD  		#while content(c_idx) not null terminator, branch to first IF statement for alphabetical chars
    	j STARTPD   		#if content(c_idx) = null, jump to STARTP (start print)

IFD:    			#IF statement for checking if char is alphabetical
    	blt  $t1, 65, ELSED   	# < A(65) ELSE or >= A(65) continue
    	ble  $t1, 90, THEND  	# <= Z(90) THEN or  > Z(90) continue
    	blt  $t1, 97, ELSED   	# < a(97) ELSE or >= a(97) continue
    	ble  $t1, 122, THEND   	# <= z(122) THEN or > z(122) continue
    
ELSED: 
    j 	STARTPD		
        
THEND:   				 
    	mul  $t3, $s1, 21  	#$t3 = (token number)*(word size + null char)
    	add  $t4, $t3, $t2	#$t4 = $t2(token_c_idx) + $t3
    	sb   $t1, dictionaryTokens($t4)   #c = dictionaryTokens(dwordscount)(chartoken)

    	add  $t0, $t0, 1   	#i += 1
    	add  $t2, $t2, 1   	#incrementing chartoken += 1
    	lb   $t1, dictionary($t0)	#set $t1 = dictionary($t1+1) (next char in content)
    	j COND			#check next char to see if alphabetical
    	
COND:
    	beq  $t1, $t5, NEWLINE
    	beqz $t1, STARTPD
    	j THEND
   	
NEWLINE:

	sb   $zero, dictionaryTokens($t0)
	add  $s1, $s1, 1
	add  $t0, $t0, 1
	lb   $t1, dictionary($t0)
	li   $t2, 0
	
	j THEND
	
STARTPD:			
	li   $t0, -1		#$t0 = i = -1
	la   $s2, ($s0)		#$s2 = number of tokens
	
	j ILOOP
#loops to compare chars and find incorrect spelled words

ILOOP:
	add  $t0, $t0, 1	#i being incremented
	li   $t1, -1 		#j = -1
	li   $s3, 0 		#correctWord = 0
	blt  $t0, $s2, JLOOP 
	beq  $t0, $s2, PRINT
	j ILOOP
	
JLOOP:
	
	add  $t1, $t1, 1	#j being incremented
	li   $s4, 0		#wrongChar = 0
	li   $t2, -1		#k = -1
	li   $s5, 21		#MAX_WORD_SIZE = 20 + 1 for null char
	blt  $t1, $s1, KLOOP	#if j < dwordcount
	beq  $t1, $s1, SETCORRECTWORDARRAY	#if j = dwordcount
	
	j JLOOP

SETCORRECTWORDARRAY:
	beq  $s3, 1, SET1
	j SET0

SET1:
	sb   $s3, correctWords($t0)
	j ILOOP
	
	
	
	
SET0:
	sb   $s3, correctWords($t0)
	j ILOOP
	
KLOOP:	
	add  $t2, $t2, 1
	beq  $t2, $s5, CORRECTWORDCHECK
	mul  $t3, $t0, 2048		#$t3 = the position [i][k]
	add  $t3, $t3, $t2
	mul  $t4, $t1, 21		#$t4 = the position [j][k]
	add  $t4, $t4, $t2		
	lb   $t5, token($t3)		#$t5 = token[i][k]
	lb   $t6, dictionaryTokens($t4)	#$t6 = dictionaryTokens[j][k]


 	blt  $t5, 65, CHECKPUN1  	# < A(65) CHECKPUN1 or >= A(65) continue
    	ble  $t5, 90, CHANGELOW		# <= Z(90) COMPARE or  > Z(90) continue
    	bge  $t5, 97, COMPARE  		# > a(97) COMPARE
    	ble  $t5, 122, COMPARE   	# <= z(122) COMPARE
    	
	j KLOOP

CHANGELOW:
	add  $t5, $t5, 32
	j COMPARE
CHECKPUN1:
	beq  $t5, 33, CHECKPUN2   	#not equal to 33, 44, 46, 63 jump to KLOOP
    	beq  $t5, 44, CHECKPUN2		#otherwise jump to CHECKPUN2 
    	beq  $t5, 46, CHECKPUN2
    	beq  $t5, 63, CHECKPUN2
    	beq  $t5, 32, CHECKPUN2	
    	j KLOOP
    	
CHECKPUN2:
	li   $s3, 1		#if current char is punctuation, correctWord = 1 (let it pass through)
	j KLOOP

COMPARE:
	bne  $t5, $t6, SETWRONGCHAR
	j KLOOP
	
SETWRONGCHAR:
	add  $s4, $s4, 1
	j KLOOP

CORRECTWORDCHECK:
	beq  $s4, 0, WORDISCORRECT	#if wrongChar = 0, jump to setting WORDISCORRECT
	
	j JLOOP

WORDISCORRECT:
	li   $s3, 1			#set correctWord = 1
	j JLOOP				#once k loop has finshed, jump to j loop for next iteration

#output section:
PRINT:				#start print
	li   $t0, 0
	move $t1, $s0
	
	j PRINTRIGHT

PRINTRIGHT:


	beq  $t0, $t1, END
	lb   $t3, correctWords($t0)
	#li   $v0, 1
	#move  $a0, $t3
	#syscall

	beq  $t3, 0, PRINTWRONG
	mul  $t7, $t0, 2049	#$t7 is the token number (starting at 0) * the token size
	li   $v0, 4
	la   $a0, token($t7)
	syscall 
	
	add  $t0, $t0, 1
	j PRINTRIGHT
	
PRINTWRONG:
	li   $v0, 11
	li   $a0, 95
	syscall
	
	mul  $t7, $t0, 2049	#$t7 is the token number (starting at 0) * the token size
	li   $v0, 4
	la   $a0, token($t7)
	syscall
	
	li   $v0, 11
	li   $a0, 95
	syscall
	
	add  $t0, $t0, 1
	j PRINTRIGHT
	

END:
	jal userFunction

	j endUserFunction
	
userFunction:
	move $v1, $a1
	jr $ra

endUserFunction:			
	
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
