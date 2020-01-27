; next note in memory
sfx_next_note_addr:	defs 2

sfx_playmelody:
	call	sfx_mute_psg
	ld	bc,0
	ld 	hl,sfx_playmelody_loop		; enter nop loop
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_playmelody_loop:
	ld	hl,(sfx_next_note_addr)
	ld	a,(hl)
	cp	0
	jp	Z,sfx_nop_trap			; 0 delay means we're over

	cp	c
	jp	NZ,sfx_callback_return

	push	bc
	ld	b,11
	inc	hl

	melody_psg_loop:	
		ld	a,(hl)
		ld	(psg),a
		inc	hl
		djnz melody_psg_loop
	pop	bc

	ld	(sfx_next_note_addr),hl
	
	jp	sfx_callback_return