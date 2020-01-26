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

********************************************
* Uploads the primary gameplay (level) SFX 
* program to the Z80's memory
********************************************
UploadPrimarySFXProgram:
    movem.l d0/a0-a1, -(SP)
    lea     LevelSFXDriverBegin, a0
    move.l  #LevelSFXDriverEnd-1, d0
    bsr.s   UpdateZ80Program
    movem.l (SP)+, d0/a0-a1
    rts
******************************************
* Copies the driver from a0 to shared RAM
* a0 - driver start
* a1 - Trashed
* d0 - driver end/Trashed
UpdateZ80Program:
    StopZ80
    ResetZ80
    WaitZ80

    lea.l   (z80_ram).l, a1
    sub.l   a0, d0
    sound_driver_loop:
        move.b  (a0)+, (a1)+
        dbra    d0, sound_driver_loop

    ReloadZ80
    Z80BusSync
    ReleaseZ80
    Z80BusSync
    ResetZ80
    Z80BusSync
    rts

***************************************
* Sets the address of the desired SFX
* to the Z80's callback
***************************************
* d0 - desired address
SetSFX:
    StopZ80
    WaitZ80
    move.b  d0, z80_sfx_ptr
    lsr.w   #8, d0
    move.b  d0, (z80_sfx_ptr+1)
    ReleaseZ80
    Z80BusSync
    rts