.text
# To test the hazard of lw stall

addi $v0, $zero, 114
addi $v1, $zero, 514
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
sw $v0, 4($zero) # 114 in DATA_MEM[1]
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
lw $a0, 4($zero)  # $a0 should be 114
sub $a1, $v1, $a0  # The hazard of lw stall happens
                   # $a1 shoule be 400
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards
addi $k0, $zero, 1 # meaningless instruction, just to avoid other hazards                   
sw $a1, 8($zero)  # 400 in DATA_MEM[2]