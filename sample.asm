.text

beq r0, r0, label
add r0, r0, r0
label:
addi r1, r1, 100

.data
.float 1.0, 2.0
.byte 'a', 'b', 'test', 0, 0xff, 1
.word 10, 12
.half 'this is a test'
