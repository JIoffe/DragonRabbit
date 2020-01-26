*********************************
* Damages player if vulnerability flag is set
* \1 - register to test with / trash
DamagePlayer    macro
    move.b  (MEM_player_vulnerability), \1
    btst    #player_vulnerable, \1
    beq.s   skip\@
        move.b  MEM_player_hp, \1
        subq    #1, \1
        move.b  \1, MEM_player_hp
        bne.s   notdead\@
            SilencePSG68k
            move.b  #$10, (MEM_player_vulnerability)
            move.w  #player_death_velocity, MEM_player_velocity_y       ; jump for... death?
            lea     MainLoop_Level_PlayerDead, a6                       ; Go to update loop for player death
            bra.s   skip\@
notdead\@
        moveq   #0, \1
        bset    #player_hurt_recoil, \1
        move.b  \1, (MEM_player_vulnerability)
        move.w  #player_hurt_duration, (MEM_player_inv_frames)
skip\@
    jsr UpdateHealthGfx             ; This probably doesn't change so often that it needs to be every frame
    endm

SetPlayerVulnerable     macro
    move.b  (MEM_player_vulnerability), d0
    moveq   #1, d0
    move.b d0, (MEM_player_vulnerability)
    endm

SkipWhenPlayerDead      macro
    move.b  (MEM_player_vulnerability), \1
    btst    #player_dead, \1
    bne.w   \2
    endm

**********************************
* Hurts player on touching bounding box
* \1 - BoundingBox size, assumes d1 has position
HurtPlayerIfTouching    macro
    move.l  d1, d7
    addi.l  \1, d7
    lea     return\@, a2
    jmp     CollideHazardAgainstPlayer
return\@
    endm

*********************************************
* Everyone dies, but not everyone truly lives
*********************************************
KillPlayer  macro
    SilencePSG68k
    move.b  #0, MEM_player_hp
    move.b  #$10, MEM_player_vulnerability
    move.w  #player_death_velocity, MEM_player_velocity_y       ; jump for... death?
    lea     MainLoop_Level_PlayerDead, a6                       ; Go to update loop for player death
    jsr     UpdateHealthGfx
    endm