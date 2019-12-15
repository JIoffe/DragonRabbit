chicken_recoil_frames         EQU     $18

chicken_width                 EQU     $1C
chicken_height                EQU     $18  
chicken_collision_offset      EQU     chicken_height-2
chicken_speed                 EQU     $02  
chicken_bb_offset             EQU     (chicken_height<<16)|chicken_width

Chicken_Update:
    move.l  a4, -(SP)
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    move.b  d6, d3
    andi.b  #6, d3          ; mask out health
    beq.w   chicken_done

    CancelOutOfView     chicken_done, d2, d1, #chicken_bb_offset, d3

    move.l  d2, -(SP)
    move.l  d1, d2
    addi.l  #chicken_bb_offset, d2

    GetDamageReceived

    moveq   #0, d7
    move.b  d6, d7
    lsr.b   #3, d7

    tst.b   d3
        beq.s   chicken_damage_skip
        AddBloodSpurt
        subq    #2, d6
        move.b  d6, d3
        andi.b  #6, d3
        AddBloodburstIfDead

        ; Losing all his feathers!
        move.l  d1, d3
        subi.l  #$00100000, d1
        AddFeathers
        
        move.l  d3, d1

        move.b  #chicken_recoil_frames, d7
    chicken_damage_skip:

    tst.b   d7
    beq.s   chicken_walking_anim
        subq    #1, d7
        lea     Chicken_Hurt0, a0 
        bra.s   chicken_anim_chosen
    
    chicken_walking_anim:
        ***********************************************************
        * Move until we bump into a wall or edge
        * (the mushroom naturally faces left, so "flip" means moving right)
        ***********************************************************
        move.l  d1, d3
        btst    #sprite_flip_h, d6
        bne.s   chicken_move_left
            addi.w  #chicken_speed, d1
            addi.w  #chicken_width, d3
            bra.s   chicken_moved  
        chicken_move_left:
            subi.w  #chicken_speed, d1
            subq    #1, d3
        chicken_moved:

        **********************************
        * Bump against the edges
        **********************************
        BumpAgainstEdgesMacro   #chicken_collision_offset

        movea.l a4, a0
        subq    #4, a0
        move.l  d1, (a0)                          ; Update position in RAM

        ; Only two frames...
        move.w  (frame_counter), d3
        add.w   a4, d3                      ; mix it up a little bit to make them look more random
        ToggleFrames    #16, Chicken_Walking0, Chicken_Walking1, d3
    chicken_anim_chosen:

    asl.b   #3, d7
    andi.b  #7, d6                          ; mask out the flip flags
    add.b   d7, d6

    moveq   #0, d7
    move.w  #cram_palette_3_bits, d7        ; chicken uses 4th palette
    move.l  (SP)+, d2                       ; restore camera from stack
    jsr     DrawSpriteFrame

    chicken_done:
    move.l  (SP)+, a0
    move.b  d6, (a0)                        ; save state updates

    jmp (a5)