;**********************************************************
; Prototype Sound Driver
;***********************************************************
; All the "sound effects" are hard-coded subroutines for now

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

sfx_collection:
	call	sfx_mute_psg
	ld	bc,0
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

	ld 	hl,sfx_collection_att
	ld 	(sfx_callback),hl
	jp	sfx_callback_return

sfx_collection_att:
	ld	a,c
	cp	10
	jp	Z,sfx_nop_trap

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

sfx_player_dead:
	ld	hl,melody_death
	ld	(sfx_next_note_addr),hl
	jp	sfx_playmelody

sfx_player_hurt:
	ld	hl,melody_player_damaged
	ld	(sfx_next_note_addr),hl
	jp	sfx_playmelody

sfx_fanfare:
	ld	hl,melody_happy_jingle
	ld	(sfx_next_note_addr),hl
	jp	sfx_playmelody

sfx_nop_trap:				; cancel all playing sounds
	call	sfx_mute_psg
	ld 	hl,sfx_nop		; enter nop loop
	ld 	(sfx_callback),hl	
sfx_nop:
	jp	sfx_callback_return

read	'./util/Play_melody.asm'

;As a test, PSG melodies have the following format:
; For each note:
; 1 byte for the delay
; 4 bytes for channel volumes
; 6 bytes for tone channel freq
; 1 byte for noise channel freq
; a delay of 0 means the melody is over
melody_death:
 db  1,%10010000,%10111111,%11011111,%11111111
 db    %10000010,%00001110,%10101001,%00100101,%11001001,%01000101,%11101001
 db  8,%10010000,%10111111,%11011111,%11111111
 db    %10001111,%00001110,%10101001,%00100101,%11001001,%01000101,%11101001
 db  17,%10010000,%10111111,%11011111,%11111111
 db    %10000010,%00001110,%10101001,%00100101,%11001001,%01000101,%11101001
 db  26,%10010000,%10111111,%11011111,%11111111
 db    %10001111,%00001110,%10101001,%00100101,%11001001,%01000101,%11101001
 db  34,%10010000,%10110000,%11011111,%11111111
 db    %10000010,%00001110,%10101010,%00111000,%11001001,%01000101,%11101001
 db  43,%10010000,%10110000,%11011111,%11111111
 db    %10001110,%00010010,%10101001,%00101111,%11001001,%01000101,%11101001
 db  52,%10010000,%10110000,%11011111,%11111111
 db    %10000111,%00010110,%10100101,%00100111,%11001001,%01000101,%11101001
 db  61,%10010000,%10110000,%11011111,%11111111
 db    %10001100,%00100101,%10101010,%00111000,%11001001,%01000101,%11101001
 db  69,%10010000,%10110000,%11011111,%11111111
 db    %10001001,%00101111,%10100011,%00111111,%11001001,%01000101,%11101001
 db  78,%10010000,%10110000,%11011111,%11111111
 db    %10001001,%00101111,%10100011,%00111111,%11001001,%01000101,%11101001
 db  0

melody_player_damaged:
 db  1,%10011111,%10110000,%11010000,%11110000
 db    %10001001,%00000101,%10101010,%00111000,%11001101,%01010100,%11100011
 db  6,%10011111,%10110000,%11010000,%11110000
 db    %10001001,%00000101,%10101111,%00111011,%11001110,%01011001,%11101100
 db  12,%10011111,%10110000,%11010000,%11110000
 db    %10001001,%00000101,%10101111,%00111011,%11001110,%01011001,%11101100
 db  0


melody_happy_jingle:
 db  1,%10010000,%10111111,%11010000,%11111111
 db    %10000000,%00010100,%10101001,%00100101,%11000000,%01010100,%11101001
 db  15,%10010000,%10111111,%11010000,%11111111
 db    %10000011,%00010101,%10101001,%00100101,%11000011,%01010101,%11101001
 db  23,%10010000,%10111111,%11010000,%11111111
 db    %10000000,%00010100,%10101001,%00100101,%11000000,%01010100,%11101001
 db  38,%10010000,%10111111,%11010000,%11111111
 db    %10001110,%00001111,%10101001,%00100101,%11001110,%01001111,%11101001
 db  46,%10010000,%10111111,%11010000,%11111111
 db    %10000101,%00001101,%10101001,%00100101,%11000101,%01001101,%11101001
 db  53,%10010000,%10111111,%11010000,%11111111
 db    %10001110,%00001000,%10101001,%00100101,%11001110,%01001000,%11101001
 db  61,%10010000,%10111111,%11010000,%11111111
 db    %10000000,%00001010,%10101001,%00100101,%11000000,%01001010,%11101001
 db  76,%10010000,%10111111,%11010000,%11111111
 db    %10001001,%00001010,%10101001,%00100101,%11001001,%01001010,%11101001
 db  84,%10010000,%10111111,%11010000,%11111111
 db    %10000000,%00001010,%10101001,%00100101,%11000000,%01001010,%11101001
 db  92,%10010000,%10111111,%11010000,%11111111
 db    %10000000,%00001010,%10101001,%00100101,%11000000,%01001010,%11101001
 db  0



