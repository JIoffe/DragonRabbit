UpdateScoreGfx
    movem.l d0-d7, -(SP)

    ; update the score in RAM
    lea.l   MEM_score_vram_data, a0
    moveq   #7, d0

    lea     UINumbers_Tiles, a2
    score_digit_loop:
        move.l  (a2)+, (a0)+
        dbra    d0, score_digit_loop

    ; Prepare DMA
    move.w  #$50, d1
    move.l  #MEM_score_vram_data, d2
    lea.l   MEM_score_vram_address, a0
    moveq   #0, d3
    move.w  (a0), d3
    jsr     TriggerDMADumpToVRAM

    movem.l (SP)+, d0-d7
    rts