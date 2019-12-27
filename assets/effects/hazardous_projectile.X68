********************************************************
* This is a projectile that goes straight left or right
********************************************************
* - This *could* be extended to match different cases,
*   though right now it's just a squirrel nut.
*
*   It disappears when offscreen

HazardousProjectile_effect:
    ; The state is the velocity per frame
    ; Assuming none of these are creeping death that move less than
    ; one pixel per frame....
    moveq   #0, d6
    move.b  (a4)+, d6
    ext.w   d6
    move.l  (a4)+, d1

    CancelOutOfView     projectile_outofview, d2, d1, #$00100010, d3
    
    ; To extend, would need a way to map to different sprites
    ; Maybe have a few indices in RAM for sprite, and store
    ; the index into that table as part of the state.
    moveq   #0, d7
    move.w  #cram_palette_3_bits, d7
    move.w  (frame_counter), d3
    andi.w  #8, d3
    cmp.w   #4, d3
    bls.s   projectile_flipped
        ori.w   #vram_hflip_bit, d7
    projectile_flipped:

    suba.l  #4, a4
    move.l  (a4), d1
    add.w   d6, d1
    move.l  d1, (a4)+       ; update new position

    movem.l d2/a2, -(SP)
    move.l  d1, d2
    addi.l  #$00100010, d2
    HurtPlayerIfTouching
    movem.l (SP)+, d2/a2

    lea     NutProjectile, a0
    jsr     DrawSprite

    jmp (a5)

    projectile_outofview:
    suba.l  #5, a4
    move.b  #0, (a4)
    adda.l  #5, a4
    jmp (a5)

