* -----------------------------------------------
* Adds BLOOOOOOOD
* -----------------------------------------------
AddBloodSpurt macro
    move.w  d7, -(SP)
    move.w  #bloodspurt_lifespan, d7
    jsr     AddEffect
    move.w  (SP)+, d7
    endm

* -----------------------------------------------
* Adds a few bursts of blood around a point
* -----------------------------------------------
AddDeathBloodBurst macro
    jsr AddBloodBurstTriangle
    endm

* -----------------------------------------------
* Make it fancy
* -----------------------------------------------
AddSparkle macro
    move.w  d7, -(SP)
    move.w  #$0100|sparkle_lifespan, d7
    jsr     AddEffect
    move.w  (SP)+, d7
    endm