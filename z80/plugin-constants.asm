psg equ &7F11
sfx_callback		equ &0008
sfx_callback_return	equ &004F
sfx_nop_trap		equ &0028

sfx_reset		equ &0014
sfx_mute_psg		equ &0018

sfx_music_addr		equ &000A
sfx_counter		equ &0004

bgm_repeat		equ &007B
bgm_norepeat		equ &006B

sfx_coredriver_size	equ &0140

; Macros for triggering BGM
macro	startbgm	song
	ld	hl, song
	ld	(sfx_music_addr), hl
	call	bgm_norepeat
	jp	sfx_nop_trap
mend

macro	startbgm_loop	song
	ld	hl, song
	ld	(sfx_music_addr), hl
	call	bgm_repeat
	jp	sfx_nop_trap
mend