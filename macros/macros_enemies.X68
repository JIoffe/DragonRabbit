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

GetDamageReceived   macro
    lea     receivedmg_test\@, a2
    jmp     RecievePlayerAttack
receivedmg_test\@
    endm

AddBloodburstIfDead macro
    bne.s   deathblood_skip\@
        AddDeathBloodBurst
deathblood_skip\@
    endm

* BackAndForthAI macro
*     endm