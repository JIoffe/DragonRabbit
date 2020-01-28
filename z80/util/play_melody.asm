; next note in memory
sfx_next_note_addr:	defs 2
sfx_melody_start_addr:	defs 2
sfx_melody_repeats:	defs 1
			defs 1	

;As a test, PSG melodies have the following format:
; For each note:
; 1 byte for the delay
; 4 bytes for channel volumes
; 6 bytes for tone channel freq
; 1 byte for noise channel freq
; a delay of 0 means the melody is over

sfx_playmelody:
	ld	a,0
	ld	(sfx_melody_repeats),a		;  Do not Repeat
	jp	sfx_melody_init
sfx_playmelody_repeat:
	ld	a,1
	ld	(sfx_melody_repeats),a		;  REPEAT!!!
sfx_melody_init:
	call	sfx_mute_psg
	ld	bc,0
	
	ld	hl,(sfx_next_note_addr)		;  Start again from first note
	ld	(sfx_melody_start_addr),hl	; whether to repeat or stop

	ld 	hl,sfx_playmelody_loop
	ld 	(sfx_callback),hl
sfx_playmelody_loop:
	ld	hl,(sfx_next_note_addr)
	ld	a,(hl)
	cp	0
	jp	NZ,sfx_melody_continue			; 0 delay means we're over
		ld	a,(sfx_melody_repeats)
		cp	0
		jp	Z,sfx_nop_trap
	
		ld	hl,(sfx_melody_start_addr)
		ld	(sfx_next_note_addr),hl
		jp	sfx_melody_init
	sfx_melody_continue:

	cp	c
	jp	NC,sfx_callback_return

	push	bc
	ld	b,11
	inc	hl

	melody_psg_loop:	
		ld	a,(hl)
		ld	(psg),a
		inc	hl
		djnz melody_psg_loop
	pop	bc
	ld	c,0

	ld	(sfx_next_note_addr),hl
	
	jp	sfx_callback_return