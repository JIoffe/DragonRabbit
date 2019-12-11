**************************************************
* Tests if given point is in range of player attack
; Check that maximum overlaps minimum
; a2 - point to return to
; d1 - min point of box to check agianst player attack box
; d2 - max point of box to check against player attack box
; d3 - holds the damage, which may be 0
; d7 - used for comparing positions
**************************************************
RecievePlayerAttack:                                                ; (abbreviated as rpa for labels)
    move.b  (MEM_player_att_strength), d3
    bne.s   rpa_checkbounds                         ; player is not attacking this frame
        jmp (a2)

    rpa_checkbounds:
    moveq   #0, d3

    move.l  (MEM_playerattack_max), d7
    sub.l   d1, d7
    bmi.s   rpa_collision_done
    tst.w   d7
    bmi.s   rpa_collision_done

    move.l  (MEM_playerattack_min), d7
    sub.l   d2, d7
    bpl.s   rpa_collision_done
    tst.w   d7
    bpl.s   rpa_collision_done

    ; return damage
    move.b  (MEM_player_att_strength), d3

    rpa_collision_done:
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

    ; test against max bound of player first to be consistent with other subroutines

    move.l  (MEM_player_pos), d3
    move.l  d3, d4
    addi.l  #player_bb_offset, d4
    sub.l   d1, d4
    bmi.s   cap_collision_done
    tst.w   d4
    bmi.s   cap_collision_done

    sub.l   d2, d3
    bpl.s   cap_collision_done
    tst.w   d3
    bpl.s   cap_collision_done

    ;return true
    moveq   #1, d7

    cap_collision_done:
    jmp (a2)