gem_width                   EQU     $10
gem_height                  EQU     $0C
gem_spacing_h               EQU     $14
gem_spacing_v               EQU     $10
gem_bb_offset               EQU     (gem_height<<16)|gem_width

gemh_bb_offset              EQU     (gem_height<<16)|(gem_spacing_h<<3)
gemv_bb_offset              EQU     (gem_height<<19)|(gem_spacing_h)

gem_points                  EQU     1

GemsH_Update:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d3

    tst.b   d6
    beq.w   gemsh_done

    CancelOutOfView     gemsh_done, d2, d3, #gemh_bb_offset, d1

    moveq   #7, d0
    lea     gemh_collision_test, a2
    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7

    gemh_loop:
        btst    d0, d6
        beq.s   gemh_skip
            move.l  d3, d1
            movem.l d1-d4/d7, -(SP)

            move.l  d1, d7
            addi.l  #gem_bb_offset, d7
            jmp     CollideAgainstPlayer
            gemh_collision_test:

            tst.b   d7
            beq.s   gemh_uncollected
                AddPoints   #gem_points
                AddSparkle
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

GemsV_Update:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d3

    tst.b   d6
    beq.w   gemsv_done

    CancelOutOfView     gemsv_done, d2, d3, #gemv_bb_offset, d1

    moveq   #7, d0
    lea     gemv_collision_test, a2
    move.w  (MEM_UI_sprite_start), d7
    addq    #1, d7

    gemv_loop:
        btst    d0, d6
        beq.s   gemv_skip
            move.l  d3, d1
            movem.l d1-d4/d7, -(SP)

            move.l  d1, d7
            addi.l  #gem_bb_offset, d7
            jmp     CollideAgainstPlayer
            gemv_collision_test:

            tst.b   d7
            beq.s   gemv_uncollected
                AddPoints   #gem_points
                AddSparkle
                bclr    d0, d6

            gemv_uncollected:
                movem.l (SP)+, d1-d4/d7
                lea     gem, a0
                move.l  d3, -(SP)
                jsr     DrawSprite
                move.l  (SP)+, d3
        gemv_skip:
        swap    d3
        addi.w  #gem_spacing_v, d3
        swap    d3
        dbra    d0, gemv_loop

    gemsv_done:
    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates
    jmp (a5)