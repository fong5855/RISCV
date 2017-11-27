     lw   x1,   0x0  (x0) # load the number of list
     addi x2,   x0,   0x00
     addi x3,   x0,   0x00
     addi x7,   x0,   0x04
for:  
     lw   x4,   0x4  (x0)
     lw   x5,   0x8  (x0)
     bge  x4,   x5,   skip
swap: 
     addi x6,   x4,   0x0
     addi x4,   x5,   0x0
     addi x5,   x6,   0x0
     sw   x4,   0x0   (x7)
     sw   x5,   0x4   (x7)
     addi x7,   x7,   0x4
skip: 
     addi x2,   x2,   0x1
     bltu x2,   x1,   for
     addi x3,   x3,   0x1
     bltu x3,   x1,   for
     lui  x31,  0x20040
     addi x31,  x31,  -4
     lui  x30,  0xfffff
     sw   x30,  0 (x31)


