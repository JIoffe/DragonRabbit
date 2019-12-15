chickenfeathers_lifespan       EQU     $C9

chickenfeathers_effect:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4), d1

    move.b  d6, d3
    subq    #1, d6

    ; Sway the feathers from side to side... s-s-ide to side!
    ; ... move every other frame
    moveq   #0, d7
    move.w  #cram_palette_3_bits, d7

    move.w  (frame_counter), d3
    add.w   a4, d3                  ; add memory address for a bit of chaos
    andi.w  #63, d3
    cmp.w   #32, d3
    blt.s   feathers_sway_left
        andi.w  #1, d3
        bne.s   feathers_swayed
        add.w   #1, d1
        bra.s   feathers_swayed
    feathers_sway_left:
        ori.w   #vram_hflip_bit, d7
        andi.w  #1, d3
        bne.s   feathers_swayed
        sub.w   #1, d1
    feathers_swayed:

    ; move feathers down at a slower rate
    move.w  (frame_counter), d3
    andi.w  #3, d3
    bne.s   feathers_fall_skip
        add.l   #$00010000, d1
    feathers_fall_skip:

    ; update position
    move.l  d1, (a4)+
    lea     ChickenFeathers, a0
    jsr     DrawSprite

    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)