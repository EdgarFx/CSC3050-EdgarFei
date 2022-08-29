.text
# To test the branch instruction beq, bne

addi $t1, $zero, 12
addi $t2, $zero, 13
addi $t3, $zero, 23
addi $v0, $zero, 0
addi $v1, $zero, 19
addi $a0, $zero, 1
addi $t0, $zero, -1
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
slt $a1, $v0, $v1
addi $v0, $v0, 1
sub $t0, $t0, $a0
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
beq $a1, $a0, -7
sw $t0, 8($zero)  # if the branch is handled correctly, 
                  # $t0 shoule be -21, and the value is stored in DATA_MEM[2]
bne $t1, $t2, 2  # since $t1 != $t2, it should branch
addi $t3, $zero, 3 # if the bne fails, $t3 will be 3; If bne succeeds, $t3 will be 23
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $a2, $zero, 1 # meaningless instruction, just to avoid other hazards
sw $t3, 12($zero) # store $t3 in DATA_MEM[3], and the value should be 23