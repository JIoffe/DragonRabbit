write './bin/levelSoundDriver.bin'	;WinAPE build target
psg equ &7F11

	org &0000
	di
	jp init

	defs    &34	; VBlank starts at &38
vblank:			
	inc	bc
	ld	hl,(sfx_callback)
	jp	(hl)
sfx_callback_return:
	ei
	reti

;Some variables in RAM
sfx_callback:	defs 2		; In effect, the current sound effect to play

init:
	im 1			; turn on V Blank interrupts
	ld sp,&2000
	
	ld hl,sfx_nop		; in a hurry to do nothing
	ld (sfx_callback),hl
	ei
	mainloop:
		jr mainloop	; Keep it busy, action happens on vblank

sfx_mute_psg:
	ld	a,%10011111
	ld	(psg),a
	ld	a,%10111111
	ld	(psg),a
	ld	a,%11011111
	ld	(psg),a
	ld	a,%11111111
	ld	(psg),a
	ret

; Boingy, boingy - player jumped
sfx_boing:
	call	sfx_mute_psg
	ld	bc,0

	ld 	a,%10010100
	ld 	(psg),a
	
	ld 	a,%10000010
	ld 	(psg),a

	ld 	a,%00001111
	ld 	(psg),a

	ld 	hl,sfx_boing_att
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_boing_att:
	ld	a,&FF
	sub	c
	cp	&F1
	jp	Z,sfx_nop_trap

	and	%00001111
	or	%10000000
	ld	(psg),a
	and	%01111111
	ld	(psg),a
	jp	sfx_callback_return

sfx_pewpew:
	call	sfx_mute_psg
	ld	bc,0

	ld 	a,%10010000
	ld 	(psg),a
	
	ld 	a,%10000010
	ld 	(psg),a

	ld 	a,%00001111
	ld 	(psg),a

	ld 	a,%11110000
	ld 	(psg),a

	ld 	a,%11100110
	ld 	(psg),a

	ld 	hl,sfx_pewpew_att
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_pewpew_att:
	ld	a,c
	cp	12
	jp	Z,sfx_nop_trap

	and	%00001111
	or	%10000000
	ld	(psg),a
	and	%01111111
	ld	(psg),a

	ld	a,c
	and	%00001111
	or	%11110000
	ld	(psg),a
	and	%00001111
	xor	%00001010
	or	%11100000
	ld	(psg),a
	jp	sfx_callback_return

sfx_slash:
	call	sfx_mute_psg
	ld	bc,0
	ld	a,%11110011
	ld	(psg),a
	ld	a,%11100101
	ld	(psg),a
	ld	a,%10110101
	ld	(psg),a
	ld	a,%10100001
	ld	(psg),a
	ld	a,%00100000
	ld	(psg),a

	ld 	hl,sfx_slash_att
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_smack:
	call	sfx_mute_psg
	ld	bc,0
	ld	a,%11110001
	ld	(psg),a
	ld	a,%11100010
	ld	(psg),a
	ld	a,%10110101
	ld	(psg),a
	ld	a,%10100111
	ld	(psg),a
	ld	a,%00101010
	ld	(psg),a

	ld 	hl,sfx_slash_att
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_slash_att:
	ld	a,c
	cp	10
	jp	Z,sfx_nop_trap
	and	%00001111
	or	%11110000
	ld	(psg),a
	and	%10111111
	ld	(psg),a

	jp	sfx_callback_return
sfx_nop_trap:				; cancel all playing sounds
	call	sfx_mute_psg
	ld 	hl,sfx_nop		; enter nop loop
	ld 	(sfx_callback),hl	
sfx_nop:
	jp	sfx_callback_return