;**********************************************************
; Prototype Sound Driver
;***********************************************************
; All the "sound effects" are hard-coded subroutines that get pushed to memory as needed

write './bin/core-sound-driver.bin'	;WinAPE build target
psg equ &7F11

	org &0000
	di
	jp init

; VBlank needs to start at &38
; Padd with variables
sfx_callback:	defs 2		; In effect, the current sound effect to play

; VBlank Interrupt Handler
	defs    &32	; VBlank starts at &38
vblank:		
	inc	bc
	ld	hl,(sfx_callback)
	jp	(hl)
sfx_callback_return:
	ei
	reti

; END VBLANK

sfx_nop_trap:				; cancel all playing sounds
	call	sfx_mute_psg
	ld 	hl,sfx_nop		; enter nop loop
	ld 	(sfx_callback),hl	
sfx_nop:
	jp	sfx_callback_return

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

read	'./util/Play_melody.asm'
__sfx_core_end: