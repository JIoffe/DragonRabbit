*===============================================================================
* Macros for loading specific levels
*===============================================================================
GotoTestRoom    macro
    Goto_Level  TestRoom_level, TESTROOM_tiles, #10368, Palettes_TESTROOM
    endm

*===============================================================================
* Macros for streaming through level data to keep the level loop neat
*===============================================================================
* - \1 = Column to target (in bytes)
* - d2 = camera pos YYXX
*-------------------------------------------------------------------------------
StreamLevel    macro
    move.l  a1, a0                              ; keep a1 fresh

    moveq   #0, d6
    move.w  (a0)+,  d6                          ; D2 has height (tiles)

    moveq   #0, d3
    move.w  (a0)+,  d3                          ; D3 has width (tiles)
    add.l   d3, d3

    moveq   #0, d7                              ; Adjust column based on camera
    move.w  d2, d7
    andi.w  #vdp_plane_pixel_width-1, d7        ; Clamp to plane width

    move.w  d7, d4                              ; Floor to multiple of 8, then / 8, * 2
    andi.w  #7, d4                              
    sub.w   d4, d7
    lsr.w   #2, d7

    addi.w  \1, d7                              ; Target A specific column in the view
    andi.w  #vdp_plane_byte_width-1,  d7        ; Clamp to plane byte width

    swap    d7
    addi.l  #vdp_write_plane_a, d7              ; d7 holds address for vdp

    ; For each iteration of the loop, we have
    ; to get the appropriate tile in the source data
    ; set a1 to the column we're looking at
    moveq   #0, d5
    move.w  d2, d5      
    asr.w   #3, d5                              ; See camera column offset
    add.w   d5, d5

    addi.l  \1, d5                              ; Add target column offset
    add.l   d5, a0
    
    moveq   #0, d0
    move.b  #vdp_plane_tile_height, d0
loop\@
        move.l  d7, vdp_control
        move.w  (a0),  vdp_data
        swap    d7
        addi.w  #vdp_plane_byte_width,  d7
        swap    d7
        add.l   d3, a0                          ; advance one row in the level data
        dbra    d0, loop\@

    endm

*===============================================================================
* Same as above but meant to veer left. Repeat first column out of bounds
*===============================================================================
* - \1 = Column to target (in bytes)
*-------------------------------------------------------------------------------
StreamLevelLeft    macro
    move.l  a1, a0                              ; keep a1 fresh

    moveq   #0, d6
    move.w  (a0)+,  d6                          ; D6 has height (tiles)

    moveq   #0, d3
    move.w  (a0)+,  d3                          ; D3 has width (tiles)
    add.l   d3, d3

    moveq   #0, d7                              ; Adjust column based on camera
    move.w  d2, d7
    andi.w  #vdp_plane_pixel_width-1, d7        ; Clamp to plane width

    move.w  d7, d4                              ; Floor to multiple of 8, then / 8, * 2
    andi.w  #7, d4                              
    sub.w   d4, d7
    lsr.w   #2, d7

    addi.w  \1, d7                              ; Target A specific column in the view
    andi.w  #vdp_plane_byte_width-1,  d7        ; Clamp to plane byte width

    swap    d7
    addi.l  #vdp_write_plane_a, d7              ; d7 holds address for vdp

    ; For each iteration of the loop, we have
    ; to get the appropriate tile in the source data
    ; set a1 to the column we're looking at
    moveq   #0, d5
    move.w  d2, d5      
    asr.w   #3, d5                              ; See camera column offset
    add.w   d5, d5

    add.l   d5, a0
    
    moveq   #0, d0
    move.b  #vdp_plane_tile_height, d0
loop\@
        move.l  d7, vdp_control
        move.w  (a0),  vdp_data
        swap    d7
        addi.w  #vdp_plane_byte_width,  d7
        swap    d7
        add.l   d3, a0                          ; advance one row in the level data
        dbra    d0, loop\@

    endm

RestartLevel    macro
    move.l  MEM_level_restart_address, a0
    jmp     (a0)
    endm