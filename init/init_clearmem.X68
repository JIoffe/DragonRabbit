*-----------------------------------------------------------
* Clears all registers and system RAM - you never know!
*-----------------------------------------------------------
ClearRegisters:
    move.l  #0,d0
    move.l  d0,d1
	move.l  d0,d2
	move.l  d0,d3
	move.l  d0,d4
    move.l  d0,d5
	move.l  d0,d6
	move.l  d0,d7
	move.l  d0,a0
	move.l  d0,a1
	move.l  d0,a2
	move.l  d0,a3
	move.l  d0,a4
	move.l  d0,a5
	move.l  d0,a6
		
ClearRAM:
	move.w  #$7FF0,d0   ;loop until the stack
	move.l  ram_start,a0 
    clear_ram_loop:
		move.w  #$0000,(a0)+
		dbf     d0, clear_ram_loop
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
