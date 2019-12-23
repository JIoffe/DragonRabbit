* -----------------------------------------------
* Adds \1 points to active player score in RAM
* \1 - Amount of points to add
* -----------------------------------------------
AddPoints   macro
    lea.l   MEM_score, a0
    addi.l  \1, (a0)

    lea.l   frame_state, a0
    bset    #score_changed, (a0)
    endm