.text
# This test does not include any hazards, jump, branch
# This test only aims to test the normal function of the cpu.
# To test wheter the cpu can do other instructions correctly.

addi $v0, $zero, 1
addi $v1, $zero, 2
addiu $a0, $zero, 20
addiu $a1, $zero, 16
addiu $a2, $zero, 4
add $a3, $v0, $v1  # 3 in $a3
addi $t0, $v0, -2 # -1 in $t0
sub $t1, $a1, $a0 # -4 in $t1   1111_...._1100
subu $t2, $a0, $a1 # 4 in $t2   
slt $t3, $v1, $v0 # 0 in $t3
slt $t4, $v0, $v1 # 1 in $t4
sll $t5, $t0, 3 # 32'hfffffff8  in $t5
sllv $t6, $t0, $a2  #32'hfffffff0 in $t6
srl $t7, $t0, 3  # 32'h1fffffff in $t7
srlv $s1, $t0, $a2 # 32'h0fffffff in $t8
sra $s2, $t5, 2 # 32'hfffffffe in $s2
srav $s3, $t5, $v0 # 32'hfffffffc in $s3
and $s4, $t1, $t2 # 4 in $s4
andi $s5, $t1, 13 # 12 in $s5
or $s6, $t1, $v1 # -2 in $s6
ori $s7, $t1, 3 # -1 in $s7
nor $t8, $t1, $v1 # 1 in $t8
xor $t9, $t1, $v1 # -2 in $t9
xori $k0, $t1, -5 # 32'hffff0007 in $k0
addu $k1, $t0, $v0 # 0 in $k1
sw $v0, 0($zero)  # 1 in DATA_MEM[0]
sw $v1, 4($zero)  # 2 in DATA_MEM[1]
sw $a0, 8($zero)  # 20 in DATA_MEM[2]
sw $a1, 12($zero)  # 16 in DATA_MEM[3]
sw $a2, 16($zero) # 4 in DATA_MEM[4]
sw $a3, 20($zero)  # 3 in DATA_MEM[5]
sw $t0, 24($zero)  # -1 in DATA_MEM[6]
sw $t1, 28($zero)  # -4 in DATA_MEM[7]
sw $t2, 32($zero)  # 4 in DATA_MEM[8]
sw $t3, 36($zero) # 0 in DATA_MEM[9]
sw $t4, 40($zero)  # 1 in DATA_MEM[10]
sw $t5, 44($zero)  # 32'hfffffff8 in DATA_MEM[11]
sw $t6, 48($zero)  # 32'hfffffff0 in DATA_MEM[12]
sw $t7, 52($zero)  # 32'h1fffffff in DATA_MEM[13]
sw $s1, 56($zero) # 32'h0fffffff in DATA_MEM[14]
sw $s2, 60($zero)  # 32'hfffffffe in DATA_MEM[15]
sw $s3, 64($zero)  # 32'hfffffffc in DATA_MEM[16]
sw $s4, 68($zero)  # 4 in DATA_MEM[17]
sw $s5, 72($zero)  # 12 in DATA_MEM[18]
sw $s6, 76($zero) # -2 in DATA_MEM[19]
sw $s7, 80($zero)  # -1 in DATA_MEM[20]
sw $t8, 84($zero)  # 1 in DATA_MEM[21]
sw $t9, 88($zero)  # -2 in DATA_MEM[22] **********
lw $gp, 52($zero) # 32'h1fffffff in $gp
sw $k0, 92($zero)  # 32'hffff0007 in DATA_MEM[23]
sw $k1, 96($zero) # 0 in DATA_MEM[24]
sw $gp, 100($zero) # 32'h1fffffff in DATA_MEM[25]