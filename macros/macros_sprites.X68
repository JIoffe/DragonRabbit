*===============================================================================
* Sets the sprite flip H flag at a memory address
*===============================================================================
* - \1 = memory address
* - \2 = register to use
SetFlipH    macro
    move.b  \1, \2
    bset    #sprite_flip_h, \2
    move.b  \2, \1
    endm


*===============================================================================
* Clears the sprite flip H flag at a memory address
*===============================================================================
* - \1 = memory address
* - \2 = register to use
ClearFlipH    macro
    move.b  \1, \2
    bclr    #sprite_flip_h, \2
    move.b  \2, \1
    endm