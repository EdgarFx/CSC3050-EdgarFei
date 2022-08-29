.text
# To test the data hazard of beq and bne

addi $t1, $zero, 12
addi $t2, $zero, -2
addi $t3, $zero, 23
addi $v0, $zero, 0
addi $v1, $zero, 19
addi $a0, $zero, 1
addi $t0, $zero, -1
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a1, $zero, 0 # The loop starts here. 
addi $v0, $v0, 1  
sub $t0, $t0, $a0
slt $a1, $v0, $v1
bne $a1, $a0, -5 # If the data hazard is not handled correctly, the loop will never end
sw $t0, 8($zero)  # if the branch is handled correctly, 
                  # $t0 shoule be -2, and the value is stored in DATA_MEM[2]
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
lw $t1, 8($zero)  # $t1 should be -2
beq $t1, $t2, 2  # since $t1 = $t2, it should branch
addi $t3, $zero, 3 # If the beq succeeds, this should be skipped. Thus, $t3 should be 23
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
sw $t3, 12($zero) # store $t3 in DATA_MEM[3], which should be 23