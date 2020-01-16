* -----------------------------------------------
* Adds \1 points to active player score in RAM
* \1 - Amount of points to add
* -----------------------------------------------
AddPoints   macro
    addi.l  \1, MEM_score
    bset    #score_changed, frame_state
    endm