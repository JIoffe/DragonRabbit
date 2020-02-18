write './bin/level-sfx.bin'	;WinAPE build target
read	'./Plugin-constants.asm'
	
; Boingy, boingy - player jumped
sfx_boing:
	call	sfx_mute_psg
	ld	a, &0E
	ld	(sfx_counter), a

	ld 	a,%10010100
	ld 	(psg),a
	
	ld 	a,%10000010
	ld 	(psg),a

	ld 	a,%00001111
	ld 	(psg),a

	ld 	hl,sfx_boing_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_boing_att:
	ld	a, (sfx_counter)
	or	a
	jp	Z,sfx_nop_trap

	and	%00001111
	or	%10000000
	ld	(psg),a
	and	%01111111
	ld	(psg),a
	jp	sfx_callback_return

sfx_pewpew:
	call	sfx_mute_psg
	ld	a, 12
	ld	(sfx_counter), a

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

	ld 	hl,sfx_pewpew_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_pewpew_att:
	ld	a,(sfx_counter)
	or	a
	jp	Z,sfx_nop_trap

	neg
	add	12
	and	%00001111
	or	%10000000
	ld	(psg),a
	and	%01111111
	ld	(psg),a

	ld	a,(sfx_counter)
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
	ld	a, 10
	ld	(sfx_counter), a

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

	ld 	hl,sfx_slash_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_smack:
	call	sfx_mute_psg
	ld	a, 10
	ld	(sfx_counter), a

	ld	a,%11111011
	ld	(psg),a
	ld	a,%11100010
	ld	(psg),a
	ld	a,%10110101
	ld	(psg),a
	ld	a,%10100111
	ld	(psg),a
	ld	a,%00101010
	ld	(psg),a

	ld 	hl,sfx_slash_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_slash_att:
	ld	a,(sfx_counter)
	or	a
	jp	Z,sfx_nop_trap

	neg
	add	10
	and	%00001111
	or	%11110000
	ld	(psg),a
	and	%10111111
	ld	(psg),a

	jp	sfx_callback_return

sfx_collection:
	call	sfx_mute_psg
	ld	a, 10
	ld	(sfx_counter), a

	ld	a,%10110010
	ld	(psg),a
	ld	a,%10011010
	ld	(psg),a

	ld	a,%10100001
	ld	(psg),a
	ld	a,%00100100
	ld	(psg),a

	ld	a,%10001011
	ld	(psg),a
	ld	a,%00000010
	ld	(psg),a

	ld 	hl,sfx_collection_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return

sfx_collection_att:
	ld	a,(sfx_counter)
	or	a
	jp	Z,sfx_nop_trap

	neg
	add	10
	and	%00001111
	or	%10010000
	ld	(psg),a
	or	%10110000
	ld	(psg),a

	and	%10001111
	ld	(psg),a
	ld	a,%00000000
	ld	(psg),a 
	jp	sfx_callback_return

sfx_player_hurt:
	call	sfx_mute_psg
	ld	a, 10
	ld	(sfx_counter), a

	ld	a, %11110000
	ld	(psg), a

	ld	a, %11100011
	ld	(psg), a

	ld 	hl,sfx_player_hurt_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
sfx_player_hurt_att:
	ld	a,(sfx_counter)
	or	a
	jp	Z,sfx_nop_trap
	
	and	%00001111
	or	%11101001
	ld	(psg), a
	jp	sfx_callback_return

sfx_projectile:
	call	sfx_mute_psg
	ld	a, 12
	ld	(sfx_counter), a

	ld	a, %11110000
	ld	(psg), a

	ld	a, %11100111
	ld	(psg), a

	ld 	hl,sfx_projectile_att+sfx_coredriver_size
	ld 	(sfx_callback),hl
	jp	sfx_callback_return
	jp	sfx_nop_trap
sfx_projectile_att:
	ld	a,(sfx_counter)
	or	a
	jp	Z,sfx_nop_trap
	
	and	%00000111
	or	%11100100
	ld	(psg), a
	jp	sfx_callback_return

sfx_player_dead:
	startbgm 	death_bgm+sfx_coredriver_size

sfx_fanfare:
	startbgm 	fanfare_bgm+sfx_coredriver_size

;Player entered level, start the music
sfx_spawn:
	startbgm_loop	level_bgm+sfx_coredriver_size

sfx_oneshotbgm
	startbgm 	level_bgm+sfx_coredriver_size

death_bgm:
incbin '../assets/bgm/death.vgm'

fanfare_bgm:
incbin '../assets/bgm/fanfare.vgm'

;can be swapped out for different levels in the future
level_bgm:
incbin '../assets/bgm/level0.vgm'