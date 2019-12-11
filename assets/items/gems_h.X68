gem_width                   EQU     $10
gem_height                  EQU     $0C
gem_spacing_h               EQU     $14
gem_spacing_v               EQU     $10
gem_bb_offset               EQU     (gem_height<<16)|gem_width

GemsH_Update:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d3

    tst.b   d6
    beq.s   gemsh_done

    moveq   #7, d0
    lea     gemh_collision_test, a2
    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7

    gemh_loop:
        btst    d0, d6
        beq.s   gemh_skip
            move.l  d3, d1
            movem.l d1-d4/d7, -(SP)

            move.l  d1, d2
            addi.l  #gem_bb_offset, d2
            jmp     CollideAgainstPlayer
            gemh_collision_test:

            tst.b   d7
            beq.s   gemh_uncollected
                bclr    d0, d6

            gemh_uncollected:
                movem.l (SP)+, d1-d4/d7
                lea     gem, a0
                move.l  d3, -(SP)
                jsr     DrawSprite
                move.l  (SP)+, d3
        gemh_skip:
        addi.w  #gem_spacing_h, d3
        dbra    d0, gemh_loop

    gemsh_done:
    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)