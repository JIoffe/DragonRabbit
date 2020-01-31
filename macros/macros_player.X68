*********************************
* Damages player if vulnerability flag is set
DamagePlayer    macro
    btst    #player_vulnerable, MEM_player_vulnerability
    beq.s   skip\@
        sub.b   #1, MEM_player_hp
        jsr UpdateHealthGfx                                             ; This probably doesn't change so often that it needs to be every frame
        tst.b   MEM_player_hp
        bne.s   notdead\@
            jsr     PlayerDeathJingle
            move.b  #$10, MEM_player_vulnerability
            move.w  #player_death_velocity, MEM_player_velocity_y       ; jump for... death?
            lea     MainLoop_Level_PlayerDead, a6                       ; Go to update loop for player death
            bra.s   skip\@
notdead\@
        move.b  #2, MEM_player_vulnerability
        move.w  #player_hurt_duration, (MEM_player_inv_frames)
        jsr     PlayerHurtJingle
skip\@
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
    move.b  #0, MEM_player_hp
    move.b  #$10, MEM_player_vulnerability
    ;this is mostly used for falling into oblivion so no need to shoot the player upwards
    move.w  #0, MEM_player_velocity_y
    ;move.w  #player_death_velocity, MEM_player_velocity_y
    lea     MainLoop_Level_PlayerDead, a6                       ; Go to update loop for player death
    jsr     UpdateHealthGfx
    jsr     PlayerDeathJingle
    endm