.data		#data segment starts at addr 0x00500000 (1MB for text segment)
str1: .asciiz "Testing lb,sb,read/print_char, etc\n"			#at 0x00500000
str2: .asciiz "Please enter a char:\n"				#at 0x00500024
str3: .asciiz "The char you entered is:"			#at 0x0050003C
str4: .asciiz "\nTests for .ascii\n"				#at 0x00500058
str5: .ascii "aaa\n"						#at 0x0050006C
str6: .ascii "bbbbbbb\n"						#at 0x00500070
str7: .asciiz "ccc\n"						#at 0x00500078
str8: .asciiz "Testing for fileIO syscalls\n"				#at 0x00500080
str9: .asciiz "/tmp/file.txt"				#at 0x005000a0
str10: .asciiz "\nIf you see this, your fileIOs are cool!"	#at 0x005000b0
str11: .asciiz "num of chars printed to file:"				#at 0x005000dc
str12: .asciiz "\nBye!:D"			#at 0x005000fc
str13: .asciiz "You should see:\naaa\nbbbbbbb\nccc\nbbbbbbb\nccc\nccc\nfor those strings\n"	#at 0x00500104
half: .half 1,2						#at 0x00500148
byte: .byte 1,2,3,4					#at 0x0050014c
str14: .asciiz "\nTesting for .half,.byte\n"	#at 0x00500150
str15: .asciiz "For half, the output should be: 65539 in decimal, and you have:"	#at 0x0050016c
str16: .asciiz "\nFor byte, the output should be: 16909059 in decimal, and you have:"	#at 0x005001ac, end finally from 0x005001f0

.text
main:	
	addi $a0,$a0, 80			#load str1 addr to $a0 and print.
	sll $a0,$a0,16
	addi $v0, $zero, 4
	syscall	
		
	lui $a0, 80				#load str2 addr to $a0 and print.
	ori $a0, $a0, 36
	addi $v0, $zero, 4
	syscall

	addi $v0, $v0, 8			#$v0 has 12, read char.
	syscall
	add $t0, $zero, $v0			#char read now in $t0
	
	addi $v0, $zero, 9			#calling sbrk
	addi $a0, $zero, 4			
	syscall
	add $t1, $zero, $v0			
	sb $t0, 0($t1)	# 16th

	lui $a0, 80				#load str3 addr to $a0 and print.
	ori $a0, $a0, 60
	addi $v0, $zero, 4
	syscall

	lb $a0, 0($t1)
	addi $v0, $v0, 7			#print char
	syscall # 23th line



############################################


	addi $a0,$zero, 80			#print str4
	sll $a0, $a0, 20
	srl $a0, $a0, 4
	ori $a0, $a0, 88
	addi $v0, $zero, 4
	syscall


	lui $a0, 80				#print str5
	ori $a0, $a0, 108
	addi $v0, $zero, 4
	syscall

	lui $a0, 80				#print str6
	ori $a0, $a0, 112
	addi $v0, $zero, 4
	syscall

	lui $a0, 80				#print str7
	ori $a0, $a0, 120
	addi $v0, $zero, 4
	syscall

	lui $a0, 80				#print str13
	ori $a0, $a0, 260
	addi $v0, $zero, 4
	syscall

############################################

	lui $a0, 80				#print str8
	ori $a0, $a0, 128
	addi $v0, $zero, 4
	syscall

	lui $a0, 80				#open file
	ori $a0, $a0, 160
	addi $a1, $zero, 66
	addi $a2, $zero, 420
	addi $v0, $v0, 9
	syscall

	add $t0, $zero, $a0		#transfer the file descriptor to $t0
	addi $v0, $zero, 9			#sbrk
	addi $a0, $zero, 60
	syscall

	add $t1, $zero, $v0	#transfer the allocated mem to $t1

	add $a0, $t0, $zero		#write str10 to file
	lui $a1, 80				
	ori $a1, $a1, 176
	addi $a2, $zero, 41		
	addi $v0, $zero, 15
	syscall

	add $t2, $zero, $a0 	#transfer the num of chars written to $t2
	addi $a0, $zero, 0

	lui $a0, 80				#print str11
	ori $a0, $a0, 220
	addi $v0, $zero, 4
	syscall

	add $a0, $zero, $t2	#print num of chars written to file
	addi $t5, $zero, 3
	sub $v0, $v0, $t5
	syscall

	addi $v0, $zero, 16		#close file
	add $a0, $zero, $t0
	syscall

	lui $a0, 80				#open the file again
	ori $a0, $a0, 160
	addi $a1, $zero, 2
	addi $v0, $zero, 13
	syscall
	addi $t5, $a0, 0		

	addi $a1, $t1, 0        #read from the file to the dynamic data section
	addi $a2, $zero, 41
	addi $v0, $zero, 14
	syscall

	addi $v0, $zero, 16		#close file
	add $a0, $zero, $t5
	syscall

	addi $t0, $zero, 0
	addi $t5, $zero, 0  # nullify fds before dumping, since it may depend on your open file state 

	add $a0, $zero, $t1		#print the content read from file
	addi $v0, $zero, 4
	syscall # 97th line





############################################
	lui $a0, 80				#print str14
	ori $a0, $a0, 336
	addi $v0, $zero, 4
	syscall

	lui $t0, 80			#load half array
	ori $t0, $t0, 328


	lui $a0, 80				#print str15
	ori $a0, $a0, 364
	addi $v0, $zero, 4
	syscall

	lh $a0, 0($t0)
	sll $a0, $a0, 16
	lh $t2, 2($t0)
	or $a0, $a0,$t2

	addi $a0, $a0, 1
	addi $v0, $zero, 1
	syscall

	addi $a0, $zero, 0
	lui $a0, 80				#print str16
	ori $a0, $a0, 428
	addi $v0, $zero, 4
	syscall


	lui $t1, 80				#load byte array
	ori $t1, $t1, 332

	lb $t2, 0($t1)
	sll $t2, $t2, 24
	lb $t3, 1($t1)
	sll $t3, $t3, 16
	lb $t4, 2($t1)
	sll $t4, $t4, 8
	lb $t5, 3($t1)

	or $a0, $t2,$t3
	or $a0, $a0,$t4
	or $a0, $a0,$t5

	addi $a0, $a0, -1
	addi $v0, $zero, 1
	syscall


############################################
	addi $v0, $zero, 9			# allocate space for str
	addi $a0, $zero, 50
	syscall
	add $a0, $zero, $v0    	    # transfer the allocated mem to $a0

	addi $a1, $zero, 50 # read string from .in
	addi $v0, $zero, 8 
	syscall

	addi $v0, $zero, 4  # print the string read
	syscall

	lui $a0, 80				#print str12
	ori $a0, $a0, 252
	addi $v0, $zero, 4
	syscall

	addi $v0, $zero, 17			#exit2
	addi $a0, $zero, 55			
	syscall


