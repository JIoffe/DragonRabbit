Init_TheEnd:
    move.w	#interrupts_disable, sr
    DisableHBlank
    jsr     ResetState

    lea     EndScreenPalette, a0
	moveq   #2, d0
	bsr.w   LoadPalettes

    DMA68KtoVRAM    4064, Tiles_TitleScreen, $20
    DMA68KtoVRAM    1760, EndCaption_Tiles, 4096
    DMA68KtoVRAM    2880, Tiles_FontA, 5856


    ; re-use the title screen rabbit
    move.l  #vdp_write_plane_b, a5
    move.l  #$01010000, d5
    lea     title_rabbitR, a0
    bsr.w   Plane_DrawPattern

    move.l  #vdp_write_plane_b, a5
    move.l  #$010A0000, d5
    lea     title_rabbitR, a0
    bsr.w   Plane_DrawPatternFlipH

    move.l  #$1418007F, d5
    lea     TheEndCaption, a0
    bsr.w   Plane_DrawPattern

    lea     Ending_1, a0
    move.w  #182|cram_palette_1_bits, d6
    move.l  #vdp_write_plane_a|$00A80000, d7
    bsr.w   PrintStringNoDMA

    ; Assemble SCORE text... fitting to piggyback the MEM_score_vram_data memory address
    move.l  MEM_score, d1
    lea     EndingScore, a0
    lea.l   MEM_score_vram_data, a1
    bsr.w   StrCopy
    lea     MEM_score_vram_data, a0
    suba.l  #1, a1

    lea     SCORE_number, a3
    moveq   #0, d4
    moveq   #5, d0                  ; scan 6 decimal places
    ending_score_loop:
        moveq   #0, d2
        move.l  (a3)+, d3
        ending_score_digit_scan:
            sub.l   d3, d1
            bcs.s   ending_score_digit_scan_end
            addq    #1, d2
            bra.s   ending_score_digit_scan
        ending_score_digit_scan_end:
        add.l   d3, d1

        tst.b   d2
        bne.s   ending_append_score_digit
        tst.b   d4
        beq.s   ending_skip_digit
        ending_append_score_digit:
        moveq   #1, d4
        addi.b  #48, d2
        move.b  d2, (a1)+
        ending_skip_digit:
        dbra    d0, ending_score_loop


    move.b  #0, (a1)
    move.w  #182|cram_palette_1_bits, d6
    move.l  #vdp_write_plane_a|$06280000, d7
    bsr.w   PrintStringNoDMA

    ; copy sprites to VRAM
    move.b  #1, MEM_vblank_mode

    move.w  #interrupts_enable, sr
    rts

MainLoop_TheEnd:
    move.w  (frame_counter), d0
    andi.w  #15, d0
    cmp.w   #8, d0
    bcs.s   ending_nose_up
        lea     TitleNoseTwitchDown112, a3
        lea     TitleNoseTwitchDown122, a2
        bra.s   ending_nose_tile
    ending_nose_up:
        lea     TitleNoseTwitchUp112, a3
        lea     TitleNoseTwitchup122, a2
    ending_nose_tile:

    movea.l a3, a0
    move.l  #112,  d1
    bsr.w   SetSingleTile

    movea.l a2, a0
    move.l  #122,  d1
    bsr.w   SetSingleTile

    EndLoop