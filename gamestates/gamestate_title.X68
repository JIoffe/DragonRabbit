title_scrolldelay             EQU $40
title_scrolloffset            EQU $80

Init_Title:
    move.w	#interrupts_disable, sr
    move.w  #0, (frame_counter)
    ClearVram

    lea     Palettes_TitleScreen, a0
	moveq   #2, d0
	bsr.w   LoadPalettes

	lea     Tiles_TitleScreen, a0
    moveq   #0, d0
	move.b  #217, d0
	bsr.w   LoadTiles

    ; Draw bunny face - mirror half of the face for the full profile
    move.l  #vdp_write_plane_a, a5
    move.l  #$01030000, d5
    lea     title_rabbitR, a0
    bsr.w   Plane_DrawPattern

    move.l  #$010C0000, d5
    lea     title_rabbitR, a0
    bsr.w   Plane_DrawPatternFlipH

    ; Add block '217' which is just a black square...
    ; use this to hide the scrolling logo so it appears to come in from the right
    move.w  #27, d0
    move.l  #vdp_write_plane_a, d7
    title_border_fill:
        move.l  d7, vdp_control
        move.w  #217, vdp_data
        move.w  #217, vdp_data
        move.w  #217, vdp_data

        swap    d7
        addi.w  #vdp_plane_byte_width,  d7
        swap    d7

        dbra    d0, title_border_fill

    move.w  #$0000, (MEM_fade)
    ; From here, draw to plane b
    move.l  #vdp_write_plane_b, a5
    move.w	#interrupts_enable, sr
    rts



MainLoop_Title:
    CheckABCStart Title_NotSkipped
        GotoTestRoom
        EndLoop

    Title_NotSkipped:

    move.w  (frame_counter), d1

    ; Fade in the face a little bit; one step each 16 frames
    move.w  d1, d0
    andi.w  #7, d0
    bne.s   title_fade_done

    moveq   #0, d7
    move.w  (MEM_fade), d7
    cmp.b   #$06, d7
    bge.s   title_fade_done

    lea     palette_title_rabbit, a0
    moveq   #0, d5
    move.w  d7, d5
    mulu.w  #32, d5
    add.l   d5, a0

    moveq   #1, d0
	bsr.w   LoadPalettes

    addi.b  #$01, d7
    move.w  d7, (MEM_fade)
    title_fade_done:

    cmp.w   #title_scrolldelay, d1
    blt.s   title_scrolltitle_end
    bne.s   title_scrolltitle

    ; Draw the title logo to Plane A
    lea     title_logo, a0
    move.l  #$01150000, d5
    bsr.w   Plane_DrawPattern

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

        move.w  #0, vdp_data
        move.w  d2, vdp_data
        dbra    d0, title_scrolltitle_loop

    title_scrolltitle_end:


    ; Nose twitching rabbit!
    
    move.w	#interrupts_disable, sr
    move.w  (frame_counter), d7
    cmp.w   #100, d7
    blt.s   title_nose_twitched
    move.w  d7, d0
    andi.w  #15, d0
    bne.s   title_nose_twitch_up
        move.l  #$FFFFFFFF, d4
        lea     TitleNoseTwitchDown112, a0
        moveq   #0, d1
        move.w  #112,  d1
        bsr.w   SetSingleTile
        lea     TitleNoseTwitchDown122, a0
        moveq   #0, d1
        move.w  #122,  d1
        bsr.w   SetSingleTile
        bra.s   title_nose_twitched
    title_nose_twitch_up:
        move.w  d7, d0
        andi.w  #7, d0
        bne.s   title_nose_twitched
            move.l  #$11111111, d4
            lea     TitleNoseTwitchUp112, a0
            moveq   #0, d1
            move.w  #112,  d1
            bsr.w   SetSingleTile
            lea     TitleNoseTwitchUp122, a0
            moveq   #0, d1
            move.w  #122,  d1
            bsr.w   SetSingleTile

    title_nose_twitched:
    move.w	#interrupts_enable, sr

    * move.w  (frame_counter), d7
    * move.w  d7, d0
    * andi.w  #31, d0
    * beq.s   title_nose_twitch_up
    *     move.l  #$CCCCCCCC, d4
    *     move.l  #$BBBBBBBB, d5
    *     move.l  #$AAAAAAAA, d6

    *     lea     TitleNoseTwitchDown112, a0
    *     move.w  #112,  d1
    *     bsr.w   SetSingleTile
        
    * title_nose_twitch_up:
    *     move.w  d7, d0
    *     andi.w  #15, d0
    *     beq.s   title_nose_twitched
    *     move.l  #$FFFFFFFF, d4
    *     move.l  #$FFFFFFFF, d5
    *     move.l  #$FFFFFFFF, d6
    *     lea     TitleNoseTwitchUp112, a0
    *     move.w  #112,  d1
    *     bsr.w   SetSingleTile
    * *     lea     TitleNoseTwitchDown112, a0
    * *     move.w  #112,  d1
    * *     bsr.w   SetSingleTile

    * title_nose_twitched:


    EndLoop
