*-----------------------------------------------------------
* Joypad reading subroutines
* Input code borrows from https://huguesjohnson.com/programming/genesis
* This controller code is essentially the same everywhere you look online - there is no "better" way of doing things
*-----------------------------------------------------------

PauseGame:
	pause_loop:
	btst	#joypad_start, MEM_buttons_pressed
	bne.s	pause_start_pressed
		btst	#game_paused, frame_state
		beq.s	pause_end
		bra.s	pause_loop
	pause_start_pressed:
	bchg	#game_paused, frame_state
	move.b	#0, MEM_buttons_pressed			; clear buttons so we don't enter a loop of pause/unpause
	pause_end:
	rts
   
ReadJoypad:
	move.b	#0,(a0)
	nop					;NO Ops added to let the bus sync
	nop
	move.b	(a0),d1		; get joypad data - Start/A
	lsl.w	#2,d1		; shift them so they are at the 2 highest bits
	move.b	#$40,(a0)	; read joypad data port again
	nop					; bus synchronization
	nop					; bus synchronization
	move.b	(a0),d0		; get joypad data - C/B/Dpad
	andi.b	#$3F,d0		; C/B/Dpad in low 6 bits
	andi.b	#$C0,d1		; Start/A in high 2 bits
	or.b	d1,d0		; merge values from both registers
	not.b	d0			; flip bits so 0 means not pressed, and 1 means pressed
	move.b	d0,d1		; copy current buttons to d1
	move.b	(MEM_buttons_held),d2		; copy the last previously read buttons
	eor.b	d2,d0		; flip buttons being pressed now
	move.b	d1,(MEM_buttons_held)	; store held buttons
	and.b	d1,d0		; AND with current buttons
	move.b	d0,(MEM_buttons_pressed)	; store pressed buttons
	rts

ReadInput:
    move.w	#interrupts_disable, sr
    lea	    joypad_1_data, a0
    bsr.s   ReadJoypad
    move.w	#interrupts_enable, sr
    rts
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
