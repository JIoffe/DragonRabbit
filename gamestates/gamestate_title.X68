title_scrolldelay             EQU $40
title_scrolloffset            EQU $80

Init_Title:
    move.w	#interrupts_disable, sr
    move.w  #0, (frame_counter)
    ClearVram

    lea     Palettes_TitleScreen, a0
	moveq   #3, d0
	bsr.w   LoadPalettes

	lea     Tiles_TitleScreen, a0
	move.l  #361, d0
	bsr.w   LoadTiles

    ; Draw bunny face - mirror half of the face for the full profile
    lea     Stamp_Rabbit_Title, a0
    move.w  #$0102, d0
    move.l  #vdp_write_plane_b, a1
    move.l  #cram_palette_0_bits, d7
    bsr.w   DrawStamp

    lea     Stamp_Rabbit_Title, a0
    move.w  #$010B, d0
    bsr.w   DrawStampHFlip

    move.w  #$0000, (MEM_fade)
    move.w	#interrupts_enable, sr
    rts



MainLoop_Title:
    CheckABCStart Title_NotSkipped
        Goto_Level  MarioDemo
        EndLoop

    Title_NotSkipped:
    move.w  (frame_counter), d1
    cmp.w   #title_scrolldelay, d1
    blt.s   title_scrolltitle_end
    bne.s   title_scrolltitle

    ; Draw the title logo to Plane A
    lea     Stamp_Logo_Title, a0
    move.w  #$0115, d0
    move.l  #vdp_write_plane_a, a1
    move.l  #cram_palette_1_bits, d7
    bsr.w   DrawStamp

    title_scrolltitle:
    move.w  d1, d3

    VDPcmdScrollTilesH #1
    move.l  #$0040,   d0
    move.w  d3, d2
    lsr.w   #1, d2
    add.w   d3, d1
    add.w   #title_scrolldelay, d3

    title_scrolltitle_loop:
        move.l  d0, d2
        mulu.w  #3, d2

        add.w   #title_scrolloffset, d2
        sub.w   d3, d2

        ; Stop at 0
        bpl.s   clamped_scrolltitle_zero
        moveq   #0, d2
        clamped_scrolltitle_zero:

        move.w  d2, vdp_data
        move.w  #0, vdp_data
        dbra    d0, title_scrolltitle_loop

    title_scrolltitle_end:

    ; Fade in the rabbit face
    * move.w  d1, d2
    * divu.w  #6, d2
    * swap    d2
    * tst.w   d2
    * bne.s   title_fade_end

    * lea     Palettes_TitleScreen, a0
    * move.l  #$C, d0
    * move.l  #vdp_cram_write, vdp_control
    * move.w  (MEM_fade), d2
    * title_fade_loop:
    *     move.w  (a0)+, d1
    *     and.w   d2, d1
    *     move.w  d1, vdp_data

    *     dbra    d0, title_fade_loop
    * add.w   #$0222, d2
    * cmp.w   #$0EEE, d2
    * bne.s   title_fade_clip
    * moveq   #0, d2
    * title_fade_clip:
    * move.w  d2, (MEM_fade)
    * title_fade_end:

    EndLoop


Stamp_Rabbit_Title:
   dc.b $09
   dc.b $19
   dc.w $0000

Stamp_Logo_Title:
   dc.b $10
   dc.b $08
   dc.w $00E1

Stamp_PressStart_Title:
   dc.b $08
   dc.b $01
   dc.w $0161
