UpdateScoreGfxIfDirty:
    bclr    #score_changed, frame_state
    beq.s   score_updated
        bsr.s   UpdateScoreGfx
    score_updated:
    rts

UpdateScoreGfx
    movem.l d0-d7/a0-a3, -(SP)

    lea     MEM_score_vram_data, a0
    move.l  MEM_score, d1
    bne.s   score_nonzero
        lea     UINumbers_Tiles, a2
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2), (a0)+
        bra.s   score_dma
    score_nonzero:
    moveq   #0, d4
    moveq   #5, d0                  ; scan 6 decimal places
    lea     SCORE_number, a3
    score_render_loop:
        moveq   #0, d2
        move.l  (a3)+, d3
        score_digit_scan:
            sub.l   d3, d1
            bcs.s   score_digit_scan_end
            addq    #1, d2
            bra.s   score_digit_scan
        score_digit_scan_end:

        add.l   d3, d1

        tst.b   d4
        bne.s   score_render_digit
        tst.w   d2
        beq.s   score_digit_skip
        moveq   #1, d4

        score_render_digit:
        lea     UINumbers_Tiles, a2
        asl.w   #5, d2
        adda.l  d2, a2

        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2)+, (a0)+
        move.l  (a2), (a0)+

        score_digit_skip:
        dbra    d0, score_render_loop

    ; Prepare DMA
    score_dma:
    moveq   #0, d1
    move.w  #128, d1
    move.l  #MEM_score_vram_data, d2
    moveq   #0, d3
    move.w  MEM_score_vram_address, d3
    bsr.w   TriggerDMADumpToVRAM

    movem.l (SP)+, d0-d7/a0-a3
    rts

LoadCoreGfx:
    move.w  #$0540, d1
    move.l  #CoreGameTiles, d2
    moveq   #0, d3
    move.w  (MEM_UI_sprite_start), d3
    addq    #1, d3
    lsl.w   #5, d3
    jsr     TriggerDMADumpToVRAM
    rts

* D7 has palette information
CacheScoreSprites:
    move.w  d7, d5
    move.l  #score_label_position, d1
    moveq   #1, d4
    lea     score_label, a0
    add.w  (MEM_UI_sprite_start), d7
    addq    #1, d7
    bsr.w   DrawSprite_Untransformed

    ; setup the score sprite(s)
    lea.l   MEM_sprite_buffer+8, a2
    move.w  #score_pts_position_y, (a2)+                ; first is y offset
    move.w  #$0C02, (a2)+                               ; second is size and link
    add.w  (MEM_score_digits_id), d5
    move.w  d5, (a2)+
    move.w  #score_pts_position_x, (a2)+                ; last is x offset

    move.w  #score_pts_position_y, (a2)+                ; first is y offset
    move.w  #$0C03, (a2)+                               ; second is size and link
    move.w  d5, d3
    addq    #4, d3
    move.w  d3, (a2)+
    move.w  #(score_pts_position_x+32), (a2)+           ; last is x offset
    rts

CacheHealthSprite:
    lea.l   MEM_sprite_buffer+24, a2
    move.w  #health_sprite_y, (a2)+                     ; first is y offset
    move.w  #$0C04, d3
    move.w  d3, (a2)+                                   ; second is size and link
    move.w  d7, d3
    add.w  (MEM_UI_sprite_start), d3
    addi.w  #81, d3
    move.w  d3, (a2)+
    move.w  #health_sprite_x, (a2)+                     ; last is x offset
    rts

UpdateHealthGfx:
    movem.l d0-d7, -(SP)
    move.w  #$40, d1
    move.b  MEM_player_hp, d3
    bne.s   health_test3
        move.l  #HealthTiles0of3, d2
        bra.s   health_gfx_chosen
    health_test3:
    cmp.b   #3, d3
    bne.s   health_test2
        move.l  #HealthTiles3of3, d2
        bra.s   health_gfx_chosen
    health_test2:
        cmp.b   #2, d3
        bne.s   health_test1
            move.l  #HealthTiles2of3, d2
            bra.s   health_gfx_chosen
    health_test1:
        move.l  #HealthTiles1of3, d2
    health_gfx_chosen:

    moveq   #0, d3
    move.w  (MEM_UI_sprite_start), d3
    addi.w  #81, d3
    lsl.w   #5, d3
    jsr     TriggerDMADumpToVRAM

    movem.l (SP)+, d0-d7
    rts