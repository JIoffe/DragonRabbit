moguren_harm_anim_bit       EQU     $04
moguren_recoil_frames       EQU     $18

moguren_width               EQU     $20
moguren_height              EQU     $1F
mogu_collision_offset       EQU     moguren_height-2
mogu_bb_offset              EQU     (moguren_height<<16)|moguren_width

mogu_speed                  EQU     $01
mogu_points                 EQU     2

Moguren_Update:
    movea.l a4, a3          ; save a reference to this address to update later

    move.b  (a4)+, d6       ; STATE
    move.l  (a4)+, d1       ; YYYYXXXX POSITION

    move.b  d6, d3
    andi.b  #6, d3          ; mask out health
    beq.w   mogu_skip       ; dead as a doorknob

    CancelOutOfView     mogu_skip, d2, d1, #mogu_bb_offset, d3

    HurtPlayerIfTouching    #mogu_bb_offset
    ; check for player damage
    GetDamageReceived   #mogu_bb_offset

    tst.b   d3
    beq.s   mogu_damage_skip
        AddBloodSpurt
        subq    #2, d6
        move.b  d6, d3
        andi.b  #6, d3          ; check if HP is 0
        AddPointsAndBloodburst  #mogu_points
        move.b  #moguren_recoil_frames, d7 
        bra.s   mogu_damage_done
    mogu_damage_skip:
        move.b  d6, d7
        lsr.b   #3, d7      ; use prior "recoil" state
    mogu_damage_done:

    tst.b   d7
    bls.s   mogu_walking
        subq    #1, d7
        bra.s   mogu_skip_walking
    mogu_walking:
        move.l  d1, d3              ; d3 will hold collision check
        btst    #sprite_flip_h, d6
        beq.s   mogu_move_left
            addi.w  #mogu_speed, d1
            addi.w  #moguren_width, d3
            bra.s   mogu_moved  
        mogu_move_left:
            subi.w  #mogu_speed, d1
            subq    #1, d3
        mogu_moved:

        BumpAgainstEdgesMacro   #mogu_collision_offset
    mogu_skip_walking:

    ; update state and position
    asl.b   #3, d7
    andi.b  #7, d6      ; mask away and add the "recoil" state
    add.b   d7, d6
    move.b  d6, (a3)+
    move.l  d1, (a3)+

    mogu_render:
    tst.b   d7
    beq.s   mogu_render_walking
    mogu_render_stunned:
        lea     Moguren_Hurt0, a0 
        bra.s   mogu_frame_chosen
    mogu_render_walking:
    move.w  frame_counter, d3
    add.w   a3, d3              ; add item pointer for some randomness
    ToggleFrames    #32, Moguren_Walking0, Moguren_Walking1, d3
    mogu_frame_chosen:

    andi.b  #7, d6
    moveq   #0, d7
    jsr     DrawSpriteFrame

    mogu_skip:
    jmp (a5)