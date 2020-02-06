psg equ &7F11
sfx_callback		equ &0004
sfx_callback_return	equ &0044
sfx_nop_trap		equ &0026

sfx_reset		equ &0012
sfx_mute_psg		equ &0016
sfx_next_note_ptr	equ &0006
sfx_melody_start_ptr	equ &0008
sfx_counter		equ &000B
sfx_tempo		equ &000C

sfx_note_fade_rate	equ &0010
sfx_fade_accumulator	equ &0011
	
sfx_playmelody		equ &0053
sfx_playmelody_repeat	equ &0059

sfx_coredriver_size	equ &00DE


; Macros for triggering melodies
macro trigger_melody melody,tempo
	ld	hl,melody
	ld	(sfx_melody_start_ptr),hl

	ld	a,tempo
	ld	(sfx_tempo),a

	jp	sfx_playmelody
mend

macro trigger_melody_repeat melody,tempo
	ld	hl,melody
	ld	(sfx_melody_start_ptr),hl

	ld	a,tempo
	ld	(sfx_tempo),a

	jp	sfx_playmelody_repeat
mend