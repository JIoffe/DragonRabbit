*-----------------------------------------------------------
* Blocks until the vblank flag is turned on
* (assumes frame_state and vblank_on_flag are memory constants)
*-----------------------------------------------------------
WaitVBlank:
	bclr	#vblank_on_flag, frame_state
	beq.s	WaitVBlank
	rts
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
