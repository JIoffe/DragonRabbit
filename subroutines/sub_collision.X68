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


*     **************************************************
* * Tests if given point is in range of player attack
* ; a2 - point to return to
* ; d1 - position to test
* ; d3 - holds the damage, which may be 0
* ; d4 - working value for position to test
* ; d6, d7 - used for comparing positions
* **************************************************
* RecievePlayerAttack:                                                ; (abbreviated as rpa for labels)
*     move.b  (MEM_player_att_strength), d3
*     bne.s   rpa_checkbounds
*         jmp (a2)
*     rpa_checkbounds:
*     move.b  d6, -(SP)
*     move.l  (MEM_playerattack_min), d6
*     move.l  (MEM_playerattack_max), d7
*     cmp.w   d6, d1
*     bge.s   rpa_check_max_x
*         moveq   #0, d3                      ; X min failed
*         move.b  (SP)+, d6
*         jmp (a2)

*     rpa_check_max_x:
*     cmp.w   d7, d1
*     ble.s   rpa_check_min_y
*         moveq   #0, d3                      ; X max failed
*         move.b  (SP)+, d6
*         jmp (a2)

*     rpa_check_min_y:
*     move.l  d1, d4

*     swap    d4                              ; swap everything to get to the Y word
*     swap    d6
*     swap    d7
*     cmp.w   d6, d4
*     bge.s   rpa_check_max_y
*         moveq   #0, d3                      ; Y min failed
*         move.b  (SP)+, d6
*         jmp (a2)

*     rpa_check_max_y:
*     cmp.w   d7, d4  
*     ble.s   rpa_collided
*         moveq   #0, d3                      ; Y max failed
*     rpa_collided:
*     move.b  (SP)+, d6
*     jmp (a2)