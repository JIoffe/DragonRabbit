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
    bcc.s   toggle_b\@
    lea     \2, a0
    bra.s   toggle_done\@
toggle_b\@
    lea     \3, a0
toggle_done\@
    endm

*===============================================================================
* Points a0 to the active sprite in RAM sprite buffer
* \1 - register with next sprite index
* \2 - register to trash
* \3 - register to hold address of next sprite
*===============================================================================
PointToNextSprite   macro
    ; each sprite takes up 8 bytes in the buffer
    lea.l   MEM_sprite_buffer, \3
    moveq   #0, \2
    move.w  \1, \2
    subq    #1, \2
    asl.w   #3, \2
    adda.l  \2, \3
    endm

DMADumpSpriteBuffer   macro
    moveq   #0, d1
    move.w  #320, d1
    move.l  #MEM_sprite_buffer, d2
    move.l  #vram_sprites_address, d3
    bsr.w   TriggerDMADumpToVRAM
    endm