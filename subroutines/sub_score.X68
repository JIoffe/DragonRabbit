UpdateScoreGfx
    movem.l d0-d7, -(SP)

    lea.l   UINumbers_Tiles, a0
    moveq   #8, d0
    moveq   #0, d1
    move.w  (MEM_score_digits_id), d1
    subq    #1, d1
    jsr     LoadTilesOffset

    movem.l (SP)+, d0-d7
    rts