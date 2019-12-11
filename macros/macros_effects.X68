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
    move.w  d7, -(SP)
    move.l  d1, -(SP)
    move.w  #bloodspurt_lifespan, d7

    subi.w   #16, d1
    jsr     AddEffect

    addi.w   #32, d1
    jsr     AddEffect

    subi.l  #$00100010, d1
    jsr     AddEffect

    move.l  (SP)+, d1   
    move.w  (SP)+, d7
    endm