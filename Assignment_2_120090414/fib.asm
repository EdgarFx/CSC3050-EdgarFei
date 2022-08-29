.data
# .align 2
FIB_START: .asciiz "fib("
# .align 2
FIB_MID: .asciiz ") = "
# .align 2
LINE_END: .asciiz "\n"
.text
addi $v0, $zero, 5
syscall
add $s1, $zero, $v0


lui $at, 80
ori $a0, $at, 0
addi $v0, $zero, 4
syscall

addu $a0, $s1, $zero
addi $v0, $zero, 1
syscall

lui $at, 80
ori $a0, $at, 8
addi $v0, $zero, 4
syscall

add $a0, $zero, $s1
jal fibonacci
add $a0, $zero, $v0
addi $v0, $zero, 1
syscall

lui $at, 80
ori $a0, $at, 16
addi $v0, $zero, 4
syscall

addi $v0, $zero, 10
syscall



fibonacci:
addi $sp, $sp, -12 # 26
sw $ra, 8($sp)
sw $s0, 4($sp)
sw $s1, 0($sp)
add $s0, $a0, $zero
addi $v0, $zero, 1
slti $t7, $s0, 3
bne $t7, $zero, fibonacciExit # 33
addi $a0, $s0, -1
jal fibonacci # 35
add $s1, $zero, $v0
addi $a0, $s0, -2
jal fibonacci
add $v0, $s1, $v0
fibonacciExit:
lw $ra, 8($sp)
lw $s0, 4($sp)
lw $s1, 0($sp)
addi $sp, $sp, 12
jr $ra
