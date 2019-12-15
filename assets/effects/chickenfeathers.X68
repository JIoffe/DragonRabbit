chickenfeathers_lifespan       EQU     $19

chickenfeathers_effect:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4), d1

    subq    #1, d6

    ; Sway the feathers from side to side... s-s-ide to side!
    move.w  #cram_palette_3_bits, d7
    moveq   #0, d3
    move.b  d6, d3
    add.w   d3, d3
    andi.w  #2020, d3
    add.w   d3, d3
    add.w   (frame_counter), d3
    andi.w  #255, d3
    cmp.w   #128, d3
    blt.s   feathers_sway_left
        addi.w  #$0001, d1
        ori.w   #vram_hflip_bit, d7
        bra.s   feathers_sway_done
    feathers_sway_left:
        subi.w  #$0001, d1
    feathers_sway_done:

    ; Drop one pixel every 4 frames
    add.w   (frame_counter), d3
    andi.w  #4, d3
    bne.s   feather_fall_done
        addi.l  #$00010000, d1
    feather_fall_done:

    move.l  d1, (a4)+

    lea     ChickenFeathers, a0
    jsr     DrawSprite

    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)