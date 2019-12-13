*===============================================================================
* Clamps a register to 0 if minus flag is set
*===============================================================================
ClampToZero    macro
    bpl.s   clamped\@
    moveq   #0, \1
clamped\@
    endm