.text
# To test the data hazard about jr

addi $v0, $zero, 72
addi $k0, $zero, 104
addi $s0, $zero, -1
addi $s1, $zero, -2
addi $s2, $zero, -4
addi $s3, $zero, -8
addi $s4, $zero, -16
addi $s5, $zero, -32
addi $a0, $zero, 1
addi $a1, $zero, 1
addi $a2, $zero, 1
addi $t0, $zero, 1
addi $t1, $zero, 1
addi $t2, $zero, 1
addi $v1, $zero, 116
sw $v1, 0($zero) # 116 is stored in MEM[0]
addi $v0, $zero, 84
jr $v0 # The first jr
addi $s0, $zero, 3 # if jr succeeds, this should be skipped
addi $s1, $zero, 3 # if jr succeeds, this should be skipped
addi $s2, $zero, 3 # if jr succeeds, this should be skipped
                    # first jr jumps to here
addi $a0, $zero, 2 # $a0 shoule be 2
addi $a1, $zero, 4 # $a1 should be 4
addi $a2, $zero, 8 # $a2 should be 8
lw $k0, 0($zero) # $k0 is 116
jr $k0  # The second jr
addi $s3, $zero, 3 # if jr succeeds, this should be skipped
addi $s4, $zero, 3 # if jr succeeds, this should be skipped
addi $s5, $zero, 3 # if jr succeeds, this should be skipped
                    # second jr jumps to here
addi $t0, $zero, 16 # $t0 shoule be 16
addi $t1, $zero, 32 # $t1 should be 32
addi $t2, $zero, 64 # $t2 should be 64
sw $a0, 0($zero)  # 2 in DATA_MEM[0]
sw $a1, 4($zero)  # 4 in DATA_MEM[1]
sw $a2, 8($zero)  # 8 in DATA_MEM[2]
sw $t0, 12($zero) # 16 in DATA_MEM[3]
sw $t1, 16($zero) # 32 in DATA_MEM[4]
sw $t2, 20($zero) # 64 in DATA_MEM[5]
sw $s0, 24($zero) # -1 in DATA_MEM[6]
sw $s1, 28($zero) # -2 in DATA_MEM[7]
sw $s2, 32($zero) # -4 in DATA_MEM[8]
sw $s3, 36($zero) # -8 in DATA_MEM[9]
sw $s4, 40($zero) # -16 in DATA_MEM[10]
sw $s5, 44($zero) # -32 in DATA_MEM[11]