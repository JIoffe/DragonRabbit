*===============================================================================
* Sets the sprite flip H flag at a memory address
*===============================================================================
* - \1 = memory address
SetFlipH    macro
    move.b  \1, d6
    bset    #sprite_flip_h, d6
    move.b  d6, \1
    endm


*===============================================================================
* Clears the sprite flip H flag at a memory address
*===============================================================================
* - \1 = memory address
ClearFlipH    macro
    move.b  \1, d6
    bclr    #sprite_flip_h, d6
    move.b  d6, \1
    endm