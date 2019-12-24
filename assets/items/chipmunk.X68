chipmunk_recoil_frames         EQU     $18

chipmunk_width                 EQU     $2D
chipmunk_height                EQU     $2E 
chipmunk_collision_offset      EQU     chipmunk_height-2 
chipmunk_bb_offset             EQU     (chipmunk_height<<16)|chipmunk_width

chipmunk_right_spit_src        EQU     $000D001F
chipmunk_left_spit_src         EQU     $000DFFF9

chipmunk_points                EQU     100

Chipmunk_Update:
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    tst.b   d6
    beq.w   chipmunk_done
    CancelOutOfView     chipmunk_done, d2, d1, #chipmunk_bb_offset, d3

    move.l  d2, -(SP)
    move.l  d1, d2
    addi.l  #chipmunk_bb_offset, d2
    GetDamageReceived

    ; mask out the health
    move.b  d6, d7
    andi.b  #7, d6
    lsr.b   #3, d7

    tst.b   d3
    beq.s   chipmunk_damage_skip
        AddBloodSpurt
        subq    #1, d6
        tst.b   d6
        AddPointsAndBloodburst  #chipmunk_points

        move.b  #chipmunk_recoil_frames, d7
        movea.l a4, a0
        suba.l  #5, a0
        move.b  d6, (a0)                        ; save state updates
        tst.b   d6
        bne.s   chipmunk_damage_skip
            bra.w   chipmunk_done
    chipmunk_damage_skip:

    tst.b   d7
    beq.s   chipmunk_recoil_updated
        subq    #1, d7
        asl.b   #3, d7
        add.b   d7, d6

        movea.l a4, a0
        suba.l  #5, a0
        move.b  d6, (a0)                        ; save state updates
        lsr.b   #3, d7
    chipmunk_recoil_updated:

    move.w (MEM_player_pos_x), d3           ; always face the player
    cmp.w   d1, d3
    bge.s   chipmunk_flip_off
        bset    #sprite_flip_h, d6
        bra.s   chipmunk_flipped
    chipmunk_flip_off:
        bclr    #sprite_flip_h, d6
    chipmunk_flipped:

    ; Attack every so often
    move.w  (frame_counter), d3
    andi.w  #127, d3
    cmp.w   #64, d3
    blt.s   Chipmunk_NotAttacking
        bne.s   Chipmunk_spit_skip
            ; let's go NUTS
            move.l  d1, -(SP)

            btst    #sprite_flip_h, d6
            bne.s   chipmunk_spit_left
                move.w  #$0303, d7
                addi.l  #chipmunk_right_spit_src, d1
                bra.s   chipmunk_spit_chosen
            chipmunk_spit_left:
                move.w  #$03FC, d7
                addi.l  #chipmunk_left_spit_src, d1
            chipmunk_spit_chosen:    

            jsr     AddEffect

            move.l  (SP)+, d1
        Chipmunk_spit_skip:     
                    
        lea     Chipmunk_Attack0, a0
        bra.s   Chipmunk_BehaviorChosen
    Chipmunk_NotAttacking:
        tst.b   d7
        beq.s   chipmunk_nothurt
            lea     Chipmunk_Hurt0, a0
            bra.s   Chipmunk_BehaviorChosen
        chipmunk_nothurt:
            lea     Chipmunk_Idle0, a0
    Chipmunk_BehaviorChosen:

    moveq   #0, d7
    move.w  #cram_palette_3_bits, d7        ; chipmunk uses 4th palette

    move.l  (SP)+, d2                       ; restore camera from stack
    jsr     DrawSpriteFrame

    chipmunk_done:
    jmp (a5)