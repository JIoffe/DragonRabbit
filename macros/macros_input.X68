*===============================================================================
* Macros related to checking user input
*===============================================================================
*------------------------------
* Checks if A,B,C or Start buttons are pressed.
* - \1 = Label to branch to if buttons are not pressed (assumes beq.s)
*------------------------------
CheckABCStart   macro
    move.b	(MEM_buttons_pressed), d0
    andi.b  #joypad_a|joypad_b|joypad_c|joypad_start, d0
    beq.s   \1
    endm