* -----------------------------------------------
* Bump against wall and flip
* \1 - Offset to add for collision against feet
* -----------------------------------------------
BumpAgainstEdgesMacro macro
    lea     bumpchecked\@, a2
    swap    d3
    addi.w  \1, d3
    jmp     BumpAgainstEdges
bumpchecked\@
    endm

*-------------------------------------------
* Checks if player attack intersects bounding box,
* returns received damage in d3. assumes position in d1
* \1 - Size of bounding box to compute
GetDamageReceived   macro
    move.l  d1, d3
    addi.l  \1, d3
    lea     receivedmg_test\@, a2
    jmp     RecievePlayerAttack
receivedmg_test\@
    endm

*-------------------------------------------------
* Adds burst of blood and points
* \1 - points to add
*-------------------------------------------------
AddPointsAndBloodburst  macro
    bne.s   death_skip\@
    move.w  #sfx_pewpew, d0
    jsr     SetSFX
    AddDeathBloodBurst
    AddPoints   \1
death_skip\@
    endm

AddBloodburstIfDead macro
    bne.s   deathblood_skip\@
        AddDeathBloodBurst
deathblood_skip\@
    endm

* BackAndForthAI macro
*     endm