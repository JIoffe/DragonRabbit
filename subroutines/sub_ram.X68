*********************************************
* Clears states related to a particular level
*********************************************
ClearLevelVars:
    movem.l d0-d1, -(SP)
    move.l  MEM_score, -(SP)
    moveq   #0, d0
    moveq   #0, d1
    move.w  #(((MEM_player_inv_frames-MEM_player_state)/2)-1), d0
    lea.l   MEM_player_state, a0
    clear_level_vars_loop:
        move.w  d1, (a0)+
        dbra    d0, clear_level_vars_loop
    move.l  (SP)+, MEM_score
    movem.l (SP)+, d0-d1
    rts

ResetState:
    StopZ80
    ResetZ80
    SilencePSG68k

    move.w  #0, (frame_counter)
    ClearVram
    bsr.w   ClearCRAM
    bsr.s   ClearVSRam
    rts

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