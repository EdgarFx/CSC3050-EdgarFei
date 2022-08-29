.text
# To test the hazard of register File write and read
# That means the registers should first let the data write in, and then read the newst data

addi $v0, $zero, 3
addi $v1, $zero, 2
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
sub $v0, $v0, $v1  #$v0 should be 1
addi $a1, $zero ,1 # To create the hazard of registers write and read
addi $a1, $zero ,1 # To create the hazard of registers write and read  
sub $a2, $v0, $v1 # $a2 should be -1 (if the hazard is solved)
                  # While sub is at ID stage, fetching the register value,
                  # $a2's newest value is simultaneously be written back to the register                   
                  # if the coder falis to deal with this hazard,
                  # the result might be 1
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards
sw $a2, 8($zero) # -1 in DATA_MEM[2]