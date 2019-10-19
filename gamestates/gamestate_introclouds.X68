*==========================
* Constants
*==========================
intro_cloud_fill        EQU $07
lightning_bg            EQU $0A60
lightning_flicker       EQU $0ECA
nolightning_bg          EQU $0000

Init_IntroClouds:
    move.w	#interrupts_disable, sr
    move.w  #0, (frame_counter)
    ClearVram

	lea     Palettes_intro_storm, a0
	moveq   #4, d0
	bsr.w   LoadPalettes
	
	lea     Tiles_intro_storm, a0
	move.l  #17, d0
	bsr.w   LoadTiles
	
    ; Fill sky with dark cloud color
    move.l  #vdp_write_plane_b, vdp_control
    move.l  #intro_cloud_fill, d0
    mulu.w  #$40, d0
    subq    #1, d0
    cloud_fill:
        move.w  #$11, vdp_data
        dbra    d0, cloud_fill

	move.w  #(intro_cloud_fill<<8)|$003C, d0        ; Move d0 to cloud fill line and end of plane
    move.l  #vdp_write_plane_b, a1
    move.l  #cram_palette_0_bits, d7
	init_introclouds_loop:
        lea     stamp_introclouds, a0
        bsr.w   DrawStamp

        tst.b   d0
        beq.s   end_init_introclouds_loop

        subq    #4, d0
        bra.s   init_introclouds_loop
    end_init_introclouds_loop:


    ; Load LIGHTNING BOLLTTTTT
	lea     tiles_lightningA, a0
	move.l  #123, d0
    moveq   #0,  d1
    move.b  #17, d1
	bsr.w   LoadTilesOffset

    ; KILLER RABBIT
    lea     tiles_intro_fight, a0
	move.l  #257, d0
    move.b  #140, d1
	bsr.w   LoadTilesOffset

    ; For the rest of this state we can just draw patterns to plane A
    move.l  #vdp_write_plane_a, a5

    move.w	#interrupts_enable, sr
    rts

MainLoop_Clouds:
    CheckABCStart Clouds_NotSkipped
        Goto_Title
        EndLoop

    Clouds_NotSkipped:

    ; Skip to the top of the cloudes
    VDPcmdScrollTilesH #intro_cloud_fill
    lea     CloudScrollValues, a0
    move.w  (frame_counter), d1
    move.w  d1, d4
    
    cmp.w   #404, d4
    bge.s   intro_clouds_finished
    moveq   #0, d2
    move.b  (a0)+, d2
    cloud_scroll_loop:
        moveq   #0, d3
        move.b  (a0)+, d3
        scrollLinesH d3, #0, d1
        lsr.w   #1, d1
        dbra    d2, cloud_scroll_loop

    intro_clouds_finished:

    ; Flash once...
    cmp.w   #80, d4
    bne.s   ic_f1
        move.l  #$09040011, d5
        bra.w   Bolt_Clouds
    ic_f1:

    cmp.w   #110, d4
    bne.s   ic_f2
        bra.w  ClearPlaneA_Clouds 
    ic_f2:

    ; Maybe lightning strikes twice
    cmp.w   #180, d4
    bne.s   ic_f3
        move.l  #$080C0011, d5
        bra.w   Bolt_Clouds
    ic_f3:

    cmp.w   #210, d4
    bne.s   ic_f4
        bra.w  ClearPlaneA_Clouds 
    ic_f4:

    cmp.w   #270, d4
    bne.s   ic_f5
        SetBG   #lightning_bg
        move.l  #$03180011, d5
        lea     intro_lightningA, a0
        bsr.w   Plane_DrawPattern

        ; Add the jump attack to the plane
        lea     intro_FightA, a0
        move.l  #$0207008C, d5
        bsr.w   Plane_DrawPattern

        lea     intro_FightB, a0
        move.l  #$1200008C, d5
        bsr.w   Plane_DrawPattern

        EndLoop
    ic_f5:

    ; Flicker a few times...
    cmp.w   #275, d4
    blt.s   ic_f6
    cmp.w   #403, d4
    bgt.s   ic_f6
        move.w  d4, d0
        andi.w  #15, d0
        tst.w   d0
        beq.s   ic_f6_on

        move.w  d4, d0
        andi.w  #7, d0
        tst.w   d0
        beq.s   ic_f6_off    
        EndLoop
        ic_f6_on:
            SetBG   #lightning_flicker
            EndLoop
        ic_f6_off:
            SetBG   #lightning_bg
            EndLoop
    ic_f6:

    ; SLASHY
    cmp.w   #404, d4                            ; 404, FACE NOT FOUND DUE TO SLASHING
    bne.s   ic_f7
        move.w	#interrupts_disable, sr
        SetBG   #nolightning_bg
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        move.l  #vdp_write_plane_b, a0
        bsr.w   ClearPlane

        lea     intro_slash_tiles, a0
        move.l  #182, d0
        bsr.w   LoadTiles

        move.w	#interrupts_enable, sr

        EndLoop
    ic_f7:

    cmp.w   #420, d4
    bne.s   ic_f8
        moveq   #0, d5
        lea     intro_slash, a0
        bsr.w   Plane_DrawPattern
        EndLoop
    ic_f8:

    cmp.w   #450, d4
    bne.s   ic_f9
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        EndLoop
    ic_f9:

    cmp.w   #470, d4
    bne.s   ic_fA
        moveq   #0, d5
        lea     intro_slash, a0
        bsr.w   Plane_DrawPatternFlipH
        EndLoop
    ic_fA:

    cmp.w   #490, d4
    bne.s   ic_fB
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        EndLoop
    ic_fB:

    cmp.w   #500, d4
    bne.s   ic_fC
        Goto_Title
    ic_fC:

    EndLoop

Bolt_Clouds:
    SetBG   #lightning_bg
    lea     intro_lightningA, a0
    bsr.w   Plane_DrawPattern
    EndLoop

ClearPlaneA_Clouds:
    SetBG   #nolightning_bg
    move.l  #vdp_write_plane_a, a0
    bsr.w   ClearPlane
    EndLoop

CloudScrollValues:
    dc.b    $03, $09, $09, $04, $04, $00