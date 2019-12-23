moguren_harm_anim_bit       EQU     $04
moguren_recoil_frames       EQU     $18

moguren_width               EQU     $20
moguren_height              EQU     $1F
mogu_collision_offset       EQU     moguren_height-2
mogu_bb_offset              EQU     (moguren_height<<16)|moguren_width

mogu_speed                  EQU     $01
mogu_points                 EQU     200

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
        AddPointsAndBloodburst  #mogu_points
        move.b  #moguren_recoil_frames, d7

    mogu_damage_received:
    tst.b   d7
    beq.s   mogu_walking_anim
        subq    #1, d7
        lea     Moguren_Hurt0, a0 
        bra.s   mogu_anim_chosen                    ; Mushroom also is "stunnen" by attack and will not move, skip over that logic
    
    mogu_walking_anim:
        ***********************************************************
        * Move until we bump into a wall or edge
        * (the mushroom naturally faces left, so "flip" means moving right)
        ***********************************************************
        move.l  d1, d3
        btst    #sprite_flip_h, d6
        beq.s   mogu_move_left
            addi.w  #mogu_speed, d1
            addi.w  #moguren_width, d3
            bra.s   mogu_moved  
        mogu_move_left:
            subi.w  #mogu_speed, d1
            subq    #1, d3
        mogu_moved:

        **********************************
        * Bump against the edges
        **********************************
        BumpAgainstEdgesMacro   #mogu_collision_offset

        movea.l a4, a0
        subq    #4, a0
        move.l  d1, (a0)                          ; Update position in RAM

        ; Only two frames...
        move.w  (frame_counter), d3
        add.w   a4, d3                      ; mix it up a little bit to make them look more random
        ToggleFrames    #32, Moguren_Walking0, Moguren_Walking1, d3
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