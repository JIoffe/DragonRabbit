*********************************************
* Clears states related to a particular level
*********************************************
ClearLevelVars:
    movem.l d0-d3/a0, -(SP)

    ; some variables should be retained
    move.l  MEM_score, d1
    move.l  MEM_level_restart_address, d3

    moveq   #0, d2
    lea.l   MEM_player_state, a0
    move.l  #(MEM_end-MEM_player_state-1), d0
    clear_level_ram_loop:
        move.b  d2, (a0)+
        dbra    d0, clear_level_ram_loop

    move.l  d1, MEM_score
    move.l  d3, MEM_level_restart_address
    movem.l (SP)+, d0-d3/a0
    rts

ResetState:
    movem.l d0-d7/a0-a6, -(SP)
    StopZ80
    ResetZ80
    SilencePSG68k

    bsr.w   ClearCRAM
    move.w  #0, (frame_counter)
    ClearVram
    bsr.s   ClearVSRam
    DisableHBlank
    movem.l (SP)+, d0-d7/a0-a6
    rts

***************************************************************************
* Clears the scroll RAM, assuming that H Scroll is in a table per scanline
***************************************************************************
ClearVSRam:
    movem.l  d0-d1/a1, -(SP)
    lea.l   vdp_data, a1
    move.l  #vdp_vram_hscroll, vdp_control
    moveq   #0, d0
    move.w  #31, d0
    moveq   #0, d1
    hclear_loop:
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        move.w  d1, (a1)
        dbra    d0, hclear_loop

    move.l  #vdp_vram_vscroll, vdp_control
    move.w  d1, (a1)
    move.w  d1, (a1)

    movem.l (SP)+, d0-d1/a1
    rts

MemCpy:
    memcpy_loop:
        move.b  (a0)+, (a1)+
        dbra    d0, memcpy_loop
    rts