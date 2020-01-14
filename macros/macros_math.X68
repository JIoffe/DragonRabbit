*===============================================================================
* Clamps a register to 0 if minus flag is set
*===============================================================================
ClampToZero    macro
    bpl.s   clamped\@
    moveq   #0, \1
clamped\@
    endm

* \1 - register to clamp
* \2 - value/register to clamp to
ClampToByte   macro
    cmp.b   \2, \1
    blt.s   clamped\@
        move.b  \2, \1
clamped\@
    endm

*=================================
* Absolute value of a register - after an operation that sets the flag
*=============================
Abs     macro
    bpl.s   abs\@
    neg \1
abs\@
    endm

*=================================
* Absolute value of a register - after an operation that sets the flag
*=============================
AbsWord     macro
    bpl.s   abs\@
    neg.w \1
abs\@
    endm