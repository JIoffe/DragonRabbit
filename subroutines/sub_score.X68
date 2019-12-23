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
    
    ; d7 will hold the score because 7 is a lucky number!
    move.l  (MEM_score), d7
    ; d6 will hold n of digits
    moveq   #0, d6

    score_digit_extraction:
        addq    #1, d6
        divu.w  #10, d7
        swap    d7
        move.b  d7, -(SP)
        swap    d7
        andi.l  #$0000FFFF, d7
        bne.s   score_digit_extraction


    lea.l   MEM_score_vram_data, a0

    subq    #1, d6                      ; reduce for dbra
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
    move.w  #$50, d1
    move.l  #MEM_score_vram_data, d2
    lea.l   MEM_score_vram_address, a0
    moveq   #0, d3
    move.w  (a0), d3
    jsr     TriggerDMADumpToVRAM

    movem.l (SP)+, d0-d7
    rts