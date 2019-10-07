*-----------------------------------------------------------
* Initialize Inputs (needed to run on actual hardware)
*-----------------------------------------------------------
InitJoypads:
    moveq  #$40, d0
    move.b d0, joypad_1_control
    move.b d0, joypad_2_control
    move.b d0, joypad_X_control

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
