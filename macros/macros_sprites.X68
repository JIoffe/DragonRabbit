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

*===============================================================================
* Toggles between 2 frames at the sent interval, which should be a power of 2.
* - \1 - interval
* - \2 - First frame
* - \3 - Second frame
* - \4 - Register to use for toggling
*===============================================================================
ToggleFrames    macro
    andi.w  \1-1, \4
    cmp.b   \1>>1, \4
    bge.s   toggle_b\@
    lea     \2, a0
    bra.s   toggle_done\@
toggle_b\@
    lea     \3, a0
toggle_done\@
    endm