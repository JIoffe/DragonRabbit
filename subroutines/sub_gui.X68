UpdateScoreGfx
    movem.l d0-d7, -(SP)

    ; Clear score tiles in ram
    lea.l   MEM_score_vram_data, a0
    moveq   #0, d0
    move.w  #63, d0
    moveq   #0, d1
    score_gfx_clr:
        move.l  d1, (a0)+
        dbra    d0, score_gfx_clr

    

    ; Will need to find a way to do this that does not involve
    ; divu... this punishes the player with a high score!
    ; d6 will hold n of digits
    moveq   #0, d6
    moveq   #0, d1
    lea.l   MEM_score_vram_data, a0

    ; Fake a score that is 10 times greater
    move.b  #0, -(SP)

    move.l  (MEM_score), d7
    beq.s   skip_score_digit_extraction
    score_digit_extraction:
        addq    #1, d6
        divu.w  #10, d7
        swap    d7
        move.b  d7, -(SP)
        swap    d7
        andi.l  #$0000FFFF, d7
        bne.s   score_digit_extraction

    move.b  d6, d1
    lsl.w   #5, d1
    bra.s   score_digit_advance

    skip_score_digit_extraction:
    move.b  #32, d1

    score_digit_advance:
        moveq   #0, d0
        move.b  (SP)+, d0
        lsl.w   #5, d0
        lea     UINumbers_Tiles, a2
        adda.l  d0, a2
        moveq   #7, d0
        score_digit_loop:
            move.l  (a2)+, (a0)+
            dbra    d0, score_digit_loop

        dbra    d6, score_digit_advance

    ; Prepare DMA
    move.l  #MEM_score_vram_data, d2
    lea.l   MEM_score_vram_address, a0
    moveq   #0, d3
    move.w  (a0), d3
    jsr     TriggerDMADumpToVRAM

    movem.l (SP)+, d0-d7
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