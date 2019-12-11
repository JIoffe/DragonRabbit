* -----------------------------------------------
* Adds BLOOOOOOOD
* -----------------------------------------------
AddBloodSpurt macro
    move.w  #bloodspurt_lifespan, d7
    jsr     AddEffect
    endm