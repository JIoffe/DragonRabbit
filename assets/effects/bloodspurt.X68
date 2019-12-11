bloodspurt_lifespan       EQU     $1F

bloodspurt_effect:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    lea     bloodspurt4, a0
    moveq   #0, d7
    move.b  d6, d7
    lsr.b   #3, d7
    add.w   d7, d7
    add.w   d7, d7
    adda.l  d7, a0
    subq    #1, d6

    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7
    jsr     DrawSprite

    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)