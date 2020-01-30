*==========================
* Constants
*==========================
intro_cloud_fill        EQU $07
lightning_bg            EQU $0A60
lightning_flicker       EQU $0ECA
nolightning_bg          EQU $0000


TriggerIntroFade      macro
    cmp.w   \1, d4
    bne.s   fade\@
        move.b  #2, MEM_fade
fade\@
    endm

UnfadeIntro     macro
    move.b  #%11111111, psg_tone_port
    move.b  #0, MEM_FADE
    lea     Palettes_intro_storm, a0
    moveq   #4, d0
    bsr.w   LoadPalettes
    endm


Init_IntroClouds:
    move.w	#interrupts_disable, sr
    jsr     ResetState
	
    moveq   #0, d0
    move.b  #15, d0
    moveq   #1, d1
    lea     Palette_FontA, a0
    bsr.w   LoadPaletteOffset

    DMA68KtoVRAM    5664, Tiles_intro_storm, $20

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

    ; Fill Lower half of sky with TREES
    moveq   #3, d4
    move.l  #vdp_write_plane_b, a5
    intro_tree_fill:
        lea     pattern_intro_trees, a0
        moveq   #0, d5
        move.w  d4, d5
        asl.w   #4, d5
        add.w   #$0E00, d5
        swap    d5
        bsr.w   Plane_DrawPattern
        dbra    d4, intro_tree_fill


    ; Load LIGHTNING and Rabbit fight
    DMA68KtoVRAM    3936, tiles_lightningA, 5696
    DMA68KtoVRAM    8224, tiles_intro_fight, 9632

    ; load font
    DMA68KtoVRAM    2880, Tiles_FontA, 17856

    ; start off with logo/presented by caption
    lea     PresentedByCaption, a0
    move.w  #cram_palette_1_bits+$022D, d6
    move.l  #vdp_write_plane_a|$081C0000, d7
    bsr.w   PrintStringNoDMA

    ; For the rest of this state we can just draw patterns to plane A
    move.l  #vdp_write_plane_a, a5

    moveq   #0, d0
    move.b  d0, MEM_fade

    ; clear DMA flags
    move.b  #0, MEM_vblank_mode

    move.w	#interrupts_enable, sr
    rts

MainLoop_Clouds:
    CheckABCStart Clouds_NotSkipped
        Goto_Title
        EndLoop

    Clouds_NotSkipped:

    move.b  MEM_fade, d1
    beq.s   skip_intro_fade
        ; silence any lingering thunder effects
        move.b  #$0F, d0
        sub.b   d1, d0
        ori.b   #%11110000, d0
        move.b  d0, psg_tone_port

        move.w  frame_counter, d0
        andi.w  #7, d0
        bne.s   skip_intro_fade
            lea     Palettes_intro_storm, a0
            moveq   #4, d0
            bsr.w   FadePalettes
            addq    #2, d1
            move.b  d1, MEM_fade
    skip_intro_fade:

    ; Skip to the top of the cloudes
    VDPcmdScrollTilesH #intro_cloud_fill
    lea     CloudScrollValues, a0
    move.w  (frame_counter), d1
    move.w  d1, d4
    
    cmp.w   #454, d4
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

    cmp.w   #120, d4
    bne.s   ic_clearcaption
        bra.w  ClearPlaneA_Clouds
    ic_clearcaption:

    ; Flash once...
    cmp.w   #130, d4
    bne.s   ic_f1
        lea     Palettes_intro_storm, a0
        moveq   #4, d0
        bsr.w   LoadPalettes
        move.l  #$090400B1, d5
        bra.w   Bolt_Clouds
    ic_f1:

    cmp.w   #160, d4
    bne.s   ic_f2
        bra.w  ClearPlaneA_Clouds 
    ic_f2:

    TriggerIntroFade #170

    ; Maybe lightning strikes twice
    cmp.w   #230, d4
    bne.s   ic_f3
        UnfadeIntro
        move.l  #$080C00B1, d5
        bra.w   Bolt_Clouds
    ic_f3:

    cmp.w   #260, d4
    bne.s   ic_f4
        bra.w  ClearPlaneA_Clouds 
    ic_f4:

    TriggerIntroFade #270

    cmp.w   #320, d4
    bne.s   ic_f5
        UnfadeIntro
        SetBG   #lightning_bg
        move.l  #$031800B1, d5
        lea     intro_lightningA, a0
        bsr.w   Plane_DrawPattern

        ; Add the jump attack to the plane
        lea     intro_FightA, a0
        move.l  #$0207012C, d5
        bsr.w   Plane_DrawPattern

        lea     intro_FightB, a0
        move.l  #$1200012C, d5
        bsr.w   Plane_DrawPattern

        EndLoop
    ic_f5:

    ; Flicker a few times...
    cmp.w   #325, d4
    blt.w   ic_f6

    cmp.w   #453, d4
    bgt.w   ic_f6
        ; Angry thunder 

        cmp.w   #440, d4
        bcc.s   flicker_thunder_skip
        move.b  #%11110010, psg_tone_port
        move.b  #%11101010, psg_tone_port
        move.b  #%10010111, psg_tone_port

        move.w  frame_counter, d0
        lsr.w   #2, d0
        andi.b  #%00001111, d0
        move.b  d0, d1
        ori.b   #%11110000, d1
        move.b  d1, psg_tone_port
        ori.b   #%10000011, d0
        move.b  d0, psg_tone_port
        move.b  #%00001001, psg_tone_port
        bra.s   flicker_thunder_end
        flicker_thunder_skip:
        move.b  #%10011111, psg_tone_port
        move.b  #%11111111, psg_tone_port
        flicker_thunder_end:

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
    cmp.w   #454, d4                            ; 404, FACE NOT FOUND DUE TO SLASHING
    bhi.s   ic_f7_att
    bcs.w   ic_f7
        ; silence noise channel, use one of the square wave channels instead

        move.b  #$0, mem_bonus_time
        move.b  #%10000110, psg_tone_port
        move.b  #%00000100, psg_tone_port
        move.b  #%10010000, psg_tone_port

        ; Add some noise to make it more rip and tear
        move.b  #%11100101, psg_tone_port
        move.w	#interrupts_disable, sr
        SetBG   #nolightning_bg
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        move.l  #vdp_write_plane_b, a0
        bsr.w   ClearPlane

        DMA68KtoVRAM    5824, intro_slash_tiles, $20
        move.w	#interrupts_enable, sr

        EndLoop
    ic_f7_att:
        move.b  mem_bonus_time, d0
        andi.b  #%00001111, d0
        ori.b   #%10010000, d0
        move.b  d0, psg_tone_port
        ori.b   #%11110000, d0
        move.b  d0, psg_tone_port

        move.w  frame_counter, d1
        andi.w  #3, d1
        bne.s   ic_f7
            addq    #1, d0
            move.b  d0, mem_bonus_time
    ic_f7:

    cmp.w   #470, d4
    bne.s   ic_f8
        moveq   #0, d5
        lea     intro_slash, a0
        bsr.w   Plane_DrawPattern
        EndLoop
    ic_f8:

    cmp.w   #500, d4
    bne.s   ic_f9
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        EndLoop
    ic_f9:

    cmp.w   #520, d4
    bne.s   ic_fA
        moveq   #0, d5
        lea     intro_slash, a0
        bsr.w   Plane_DrawPatternFlipH
        EndLoop
    ic_fA:

    cmp.w   #540, d4
    bne.s   ic_fB
        move.l  #vdp_write_plane_a, a0
        bsr.w   ClearPlane
        EndLoop
    ic_fB:

    cmp.w   #560, d4
    bne.s   ic_fC
        ; cut out the psg sound
        move.b  #%11111111, psg_tone_port
        move.b  #%10011111, psg_tone_port
        Goto_Title
    ic_fC:

    EndLoop

Bolt_Clouds:
    ; Lightning and THUNDER
    move.b #%11101110, psg_tone_port
    move.b #%11110000, psg_tone_port

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