Init_Licensing:
    move.w	#interrupts_disable, sr
    DisableHBlank
    jsr     ResetState
    bsr.w   UploadCoreSoundDriver

    lea     Palette_Licensing, a0
    moveq   #3, d0
    bsr.w   LoadPalettes

    DMA68KtoVRAM    2880, Tiles_FontA, $20
    DMA68KtoVRAM    1120, TESTROOM_tiles+12224, 12256

    lea     LicensingCaption, a0
    move.w  #cram_palette_1_bits, d6
    move.l  #vdp_write_plane_a|$08060000, d7
    bsr.w   PrintStringNoDMA

    move.l  #BaoLongTu_sprite_Walking0, MEM_player_previous_frame

    move.w  #2912, MEM_player_tiles_start
    
    * ; copy sprites and player sprite
    move.b  #3, MEM_vblank_mode

    move.w	#interrupts_enable, sr
    rts
Loop_Licensing:
    CheckABCStart Licensing_NotSkipped
        bra.w   LeaveLicensingScreen
    Licensing_NotSkipped:

    move.w  frame_counter, d0
    cmp.w   #300, d0
    blt.s   continue_license_screen
    LeaveLicensingScreen:
        Goto_IntroClouds
        EndLoop
    continue_license_screen:

    
    move.w  frame_counter, d0
    andi.w  #15, d0
    cmp.w   #7, d0
    bgt.s   ll_frame2
        move.l  #BaoLongTu_sprite_Walking0, MEM_player_previous_frame
        lea     Chicken_Walking0, a3
        bra.s   ll_frame_selected
    ll_frame2:
        move.l  #BaoLongTu_sprite_Walking1, MEM_player_previous_frame
        lea     Chicken_Walking1, a3
    ll_frame_selected:

    moveq   #1, d4
    lea.l   MEM_player_previous_frame, a2
    move.l  (a2), a0
    moveq   #0, d1
    move.w  (a0)+, d1
    add.w   d1, d1
    adda.l  d1, a0
    move.l  #$00200068, d1
        move.w  frame_counter, d0
        sub.w   #60, d0
        bmi.s   ll_s1_adjusted
        add.w   d0, d1
    ll_s1_adjusted:
    moveq   #0, d2
    move.w  #91, d7
    bsr.w   DrawSpriteFrame

    movea.l a3, a0
    move.l  #$004800B8, d1
        move.w  frame_counter, d0
        sub.w   #60, d0
        bmi.s   ll_s2_adjusted
        add.w   d0, d1
    ll_s2_adjusted:
    moveq   #0, d2
    move.w  #cram_palette_2_bits, d7
    jsr     DrawSpriteFrame

    jsr     CapSpriteBuffer

    EndLoop