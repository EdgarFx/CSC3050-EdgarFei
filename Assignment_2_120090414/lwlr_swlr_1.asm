.data
num1: .word 256, 255

.text
lui $t2, 80 # loading/storing in memory-order. Both lwlr_swlr_1 and lwlr_swlr_2 are considered correct, and you may just pass one of them.
ori $s0, $t2, 0 
addi $s1, $s0, 8
lwl $s2, 1($s0) 
lwr $s2, 4($s0) 
swl $s2, 2($s1) 
swr $s2, 5($s1) 

add $a0, $zero, $s2
addi $v0, $zero, 1
syscall

addi $v0, $zero, 10
syscall
