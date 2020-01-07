max_effects         EQU     $10

*********************************************
* Adds effect to effect list
* d7 - effect type and state
* d1 - effect position
AddEffect:
    move.l  d0, -(SP)
    moveq   #0, d0
    move.w  (MEM_effects_count), d0
    lea     MEM_effects, a0
    cmp.w   #max_effects, d0
    bge.s   effect_added
        mulu.w  #6, d0
        adda.l  d0, a0
        addq    #1, (MEM_effects_count)
    effect_added:

    move.w  d7, (a0)+
    move.l  d1, (a0)

    move.l  (SP)+, d0
    rts

AddBloodBurstTriangle:
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
    rts