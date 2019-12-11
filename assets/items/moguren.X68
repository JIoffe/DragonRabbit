moguren_harm_anim_bit       EQU     $04
moguren_recoil_frames       EQU     $18

moguren_width               EQU     $20
moguren_height              EQU     $1F
mogu_bb_offset              EQU     (moguren_height<<16)|moguren_width

Moguren_Update:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    move.b  d6, d3
    andi.b  #6, d3          ; mask out health
    beq.w   mogu_done

    CancelOutOfView     mogu_done, d2, d1, #mogu_bb_offset, d3

    move.l  d2, -(SP)
    move.l  d1, d2
    addi.l  #mogu_bb_offset, d2

    lea     mogu_receivedmg_test, a2
    jmp     RecievePlayerAttack
    mogu_receivedmg_test:

    moveq   #0, d7
    move.b  d6, d7
    lsr.b   #3, d7

    tst.b   d3
        beq.s   mogu_damage_received
        AddBloodSpurt
        subq    #2, d6
        move.b  d6, d3
        andi.b  #6, d3
        bne.s   mogu_death_skip
            AddDeathBloodBurst
        mogu_death_skip:
        move.b  #moguren_recoil_frames, d7

    mogu_damage_received:
    tst.b   d7
    beq.s   mogu_walking_anim
        subq    #1, d7
        lea     Moguren_Hurt0, a0 
        bra.s   mogu_anim_chosen
    
    mogu_walking_anim:
        ; Only two frames...
        move.w  (frame_counter), d3
        add.w   a4, d3                      ; mix it up a little bit to make them look more random
        andi.w  #31, d3
        cmp.b   #16, d3
        bge.s   mogu_frame_b
        lea     Moguren_Walking0, a0
        bra.s   mogu_anim_chosen
        mogu_frame_b:
        lea     Moguren_Walking1, a0
    mogu_anim_chosen:

    asl.b   #3, d7
    andi.b  #7, d6                          ; mask out the flip flags
    add.b   d7, d6

    moveq   #0, d7
    move.l  (SP)+, d2                       ; restore camera from stack
    jsr     DrawSpriteFrame

    mogu_done:
    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates

    jmp (a5)