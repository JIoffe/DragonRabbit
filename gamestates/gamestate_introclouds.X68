*==========================
* Constants
*==========================
intro_cloud_fill        EQU $07

Init_IntroClouds:
    move.w	#interrupts_disable, sr
	lea     Palettes_intro_storm, a0
	moveq   #1, d0
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
    moveq   #0, d2
    move.b  (a0)+, d2
    cloud_scroll_loop:
        moveq   #0, d3
        move.b  (a0)+, d3
        scrollLinesH d3, #0, d1
        lsr.w   #1, d1
        dbra    d2, cloud_scroll_loop

    EndLoop

CloudScrollValues:
    dc.b    $03, $09, $09, $04, $04, $00