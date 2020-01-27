goalflag_width              EQU     32
goalflag_height             EQU     72
goalflag_bb_offset          EQU     (goalflag_height<<16)|goalflag_width

GoalFlag_Update:
    movea.l a4, a3
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    CancelOutOfView     goalflag_done, d2, d1, #goalflag_bb_offset, d3

    tst.b   d6
    bne.s   goalflag_nocollision

    move.w  d4, -(SP)
    lea     goalflag_collision_return, a2
    move.l  d1, d7
    addi.l  #goalflag_bb_offset, d7
    jmp     CollideAgainstPlayer
    goalflag_collision_return:
    move.w  (SP)+, d4

    tst.b   d7
    beq.s   goalflag_nocollision
        move.l  d1, d3
        moveq   #3, d0
        flagsparkleloop:
            AddSparkle
            swap    d1
            add.w   #16, d1
            swap    d1
            dbra    d0, flagsparkleloop
        move.l  d3, d1
        move.w  #0, frame_counter
        jsr     FanfareSFX
        lea     LevelClearedLoop, a6        ; YOUR WINNER
        move.b  #1, (a3)
    goalflag_nocollision:

    lea     GoalFlag_Unrolled0, a0
    moveq   #0, d7
    moveq   #0, d6
    move.w  (MEM_UI_sprite_start), d7
    jsr     DrawSpriteFrame

    goalflag_done:

    jmp (a5)