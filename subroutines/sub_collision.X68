**************************************************
* Tests if given point is in range of player attack
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player attack box
; d2 - max point of box to check against player attack box
; d3 - holds the damage, which may be 0
; d4 - working value for position to test
; d6, d7 - used for comparing positions
**************************************************
RecievePlayerAttack:                                                ; (abbreviated as rpa for labels)
    move.b  (MEM_player_att_strength), d3
    bne.s   rpa_checkbounds                         ; player is not attacking this frame
        jmp (a2)

    rpa_checkbounds:
    moveq   #0, d3

    move.b  d6, -(SP)
    move.l  (MEM_playerattack_min), d6
    move.l  (MEM_playerattack_max), d7

    cmp.w   d6, d2
    blt.s   rpa_collision_done

    cmp.w   d7, d1
    bgt.s   rpa_collision_done

    ; X is alright, check Y
    move.l  d1, d4
    swap    d4
    swap    d2
    swap    d6
    swap    d7

    cmp.w   d6, d2
    blt.s   rpa_collision_done

    cmp.w   d7, d4
    bgt.s   rpa_collision_done

    ; return damage
    move.b  (MEM_player_att_strength), d3

    rpa_collision_done:
    move.b  (SP)+, d6
    jmp (a2)

**************************************************
* Tests if bounding box intersects current player bounding box
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player box
; d2 - max point of box to check against player box
; d3 - d4 holds player's bounding box in this subroutine
; d7 will hold the result
**************************************************
CollideAgainstPlayer: 
    moveq   #0, d7

    move.l  (MEM_player_pos), d3
    move.l  d3, d4
    addi.l  #player_bb_offset, d4

    cmp.w   d3, d2
    blt.s   cap_collision_done
    cmp.w   d4, d1
    bgt.s   cap_collision_done

    ; X is alright, check Y
    swap    d1
    swap    d2
    swap    d3
    swap    d4

    cmp.w   d3, d2
    blt.s   cap_collision_done
    cmp.w   d4, d4
    bgt.s   cap_collision_done

    ;return true
    moveq   #1, d7

    cap_collision_done:
    jmp (a2)