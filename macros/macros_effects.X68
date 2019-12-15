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

* -----------------------------------------------
* Cluck!
* -----------------------------------------------
AddFeathers macro
    move.w  d7, -(SP)
    move.w  #$0200|chickenfeathers_lifespan, d7
    jsr     AddEffect

    add.l   #$00080016, d1
    move.w  #$0200|chickenfeathers_lifespan>>1, d7
    jsr     AddEffect

    sub.w   #32, d1
    move.w  #$0200|chickenfeathers_lifespan>>2, d7
    jsr     AddEffect

    move.w  (SP)+, d7
    endm
