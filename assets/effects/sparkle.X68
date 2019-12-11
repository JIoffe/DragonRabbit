sparkle_lifespan       EQU     $18

sparkle_effect:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    lea     sparkle1, a0
    move.b  d6, d3
    subq    #1, d6

    andi.b  #7, d3
    cmp.b   #4, d3
    blt.s   sparkle_on
        lea     sparkle2, a0
        bra.s   sparkle_frame_picked
        sparkle_on:
        lea     sparkle1, a0
    sparkle_frame_picked:

    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7
    jsr     DrawSprite

    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)