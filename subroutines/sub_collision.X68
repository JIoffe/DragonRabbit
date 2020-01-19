**************************************************
* Tests if given point is in range of player attack
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player attack box
; d3 - max point of box to check against player attack box / Holds return damage
; d7 - used for comparing positions / Trashed
**************************************************
RecievePlayerAttack:                                                ; (abbreviated as rpa for labels)
    tst.b  MEM_player_att_strength
    beq.s   rpa_collision_done                         ; player is not attacking this frame

    rpa_checkbounds:
    move.l  (MEM_playerattack_max), d7
    sub.l   d1, d7
    bmi.s   rpa_collision_done
    tst.w   d7
    bmi.s   rpa_collision_done

    move.l  MEM_playerattack_min, d7
    sub.l   d3, d7
    bpl.s   rpa_collision_done
    tst.w   d7
    bpl.s   rpa_collision_done

    ; return damage
    move.b  MEM_player_att_strength, d3
    jmp (a2)

    rpa_collision_done:
    moveq   #0, d3
    jmp (a2)

**************************************************
* Tests if bounding box intersects current player bounding box
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player box
; d3 - d4 holds player's bounding box in this subroutine
; d7 - max point of box to check against player boxwill hold the result
**************************************************
CollideAgainstPlayer: 
    ; test against max bound of player first to be consistent with other subroutines
    move.l  (MEM_player_pos), d3
    move.l  d3, d4
    addi.l  #player_bb_offset, d4
    sub.l   d1, d4
    bmi.s   cap_collision_done
    tst.w   d4
    bmi.s   cap_collision_done

    sub.l   d7, d3
    bpl.s   cap_collision_done
    tst.w   d3
    bpl.s   cap_collision_done

    ;return true
    moveq   #1, d7
    jmp (a2)

    cap_collision_done:
    moveq   #0, d7
    jmp (a2)

**************************************************
* Tests if bounding box intersects current player bounding box
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player box
; d7 - max point of box to check against player box
; d3 - d4 holds player's bounding box in this subroutine
**************************************************
CollideHazardAgainstPlayer:
    movem.l d3/d4, -(SP)
    move.l  (MEM_player_pos), d3
    move.l  d3, d4
    addi.l  #player_bb_offset, d4
    sub.l   d1, d4
    bmi.s   skip_player_damage
    tst.w   d4
    bmi.s   skip_player_damage

    sub.l   d7, d3
    bpl.s   skip_player_damage
    tst.w   d3
    bpl.s   skip_player_damage

    ; Player is hit
    DamagePlayer    d3
    skip_player_damage:
    movem.l (SP)+, d3/d4
    jmp (a2)


**************************************************
* Tests if item bumps against level edges
; a2 - point to return to
; d3 - point to use to check
**************************************************
BumpAgainstEdges:
    move.l  d2, -(SP)       ; save d2 since it might hold the camera

    movea.l a1, a0
    moveq   #0, d2
    addq    #2, a0
    move.w  (a0)+, d2
    move.w  d2, -(SP)           ; push level width to stack

    ; At this point d3 is swapped so that Y is at the loword and represents the offset from position to check against
    lsr.w   #3, d3
    mulu.w  d3, d2
    swap    d3
    lsr.w   #3, d3
    add.w   d3, d2
    add.w   d2, d2
    add.l   d2, a0
    move.w  (SP)+, d2           ; restore width

    tst.w   (a0)
    bne.s   edge_bumped
    ; check under feet
    add.w   d2, d2
    add.w   d2, d2
    add.l   d2, a0
    tst.w   (a0)
    beq.s   edge_bumped
    bra.s   edge_bump_skip
        edge_bumped:
        bchg    #sprite_flip_h, d6
    edge_bump_skip:

    move.l  (SP)+, d2      ; restore camera to d2

    jmp (a2)