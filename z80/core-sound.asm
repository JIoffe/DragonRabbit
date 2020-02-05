;**********************************************************
; Prototype Sound Driver
;***********************************************************
; All the "sound effects" are subroutines that can be referenced
; one at a time by the sfx_callback_ptr variable. This can be set
; from the M68K side to start a sound effect

write './bin/core-sound-driver.bin'	;WinAPE build target
psg equ &7F11	; Port to write PSG commands to
start:
	org &0000
	di
	jp init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Some variables to take up space before int handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfx_callback:		dw sfx_nop
sfx_next_note_ptr:	dw 0
sfx_melody_start_ptr:	dw 0
sfx_melody_repeats:	db 0
sfx_counter		db 0

align	2

sfx_reset:
	xor	a
	ld	(sfx_counter), a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turns off all tones in the PSG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfx_mute_psg:
	ld	de, psg
	ld	a,%10011111
	ld	(de),a
	ld	a,%10111111
	ld	(de),a
	ld	a,%11011111
	ld	(de),a
	ld	a,%11111111
	ld	(de),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets up a callback that resumes silence of the PSG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfx_nop_trap:				
	call	sfx_reset		; cancel all playing sounds
	ld 	hl,sfx_nop		; enter nop loop
	ld 	(sfx_callback),hl	
sfx_nop:
	jp	sfx_callback_return

align	&38
vblank:	
	push    af
        push    de
        push    hl

	exx
	ld	hl, sfx_counter
	dec	(hl)			; count backwards to check against 0
	ld	hl, (sfx_callback)
	jp	(hl)
sfx_callback_return:

	pop	hl
	pop	de
	pop	af
	ei
	reti

init:	
	di
	im 1
	ld sp, &2000
	ei
endlessloop: 				; sfx advancement happens on vblank
	jr endlessloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melody Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;As a test, PSG melodies have the following format:
; For each note:
; 1 byte for the delay
; 4 bytes for channel volumes
; 6 bytes for tone channel freq
; 1 byte for noise channel freq
; a delay of 0 means the melody is over

sfx_playmelody:
	xor	a
	ld	(sfx_melody_repeats),a
	jr	sfx_melody_init
sfx_playmelody_repeat:
	ld	a,1
	ld	(sfx_melody_repeats),a
sfx_melody_init:
	call	sfx_reset

	ld	hl, (sfx_melody_start_ptr)	; point to the start of the melody
	
	ld	a, (hl)
	ld	(sfx_counter), a

	inc	hl
	ld	(sfx_next_note_ptr),hl	


	ld 	hl, sfx_playmelody_loop
	ld 	(sfx_callback),hl

sfx_playmelody_loop:
	ld	a, (sfx_counter)
	or	a
	jp	NZ, sfx_callback_return

	ld	hl, (sfx_next_note_ptr)
	ld	de, psg
	ld	b, 11
	sfx_note_parse:
		ld	a, (hl)
		ld	(de), a
		inc	hl
		djnz	sfx_note_parse

	ld	a, (hl)
	or	a
	jr	NZ, sfx_melody_continue
	; hit null termination - end the song
	ld	a, (sfx_melody_repeats)
	or	a
	jr	NZ, sfx_melody_init
sfx_melody_end:
	ld 	hl, sfx_nop_trap
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
	
sfx_melody_continue:
	inc	hl
	ld	(sfx_next_note_ptr),hl	
	ld	(sfx_counter), a

	jp	sfx_callback_return

align 2
sfx_driver_end: