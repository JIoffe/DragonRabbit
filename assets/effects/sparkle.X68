sparkle_lifespan       EQU     $18

sparkle_effect:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    move.b  d6, d3
    subq    #1, d6

    ToggleFrames    #8, sparkle1, sparkle2, d3

    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7
    jsr     DrawSprite

    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)