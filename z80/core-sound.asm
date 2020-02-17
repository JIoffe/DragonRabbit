;**********************************************************
; Prototype Sound Driver
;***********************************************************
; - Set sfx_callback to define the sound handler for the next frame
; - Uses VGM format for BGM playback. PSG tones are reserved for sound effects
; All the "sound effects" are subroutines that can be referenced
; one at a time by the sfx_callback_ptr variable. This can be set
; from the M68K side to start a sound effect

write './bin/core-sound-driver.bin'	;WinAPE build target

; Port to write PSG commands to	
psg 				equ &7F11

;YM2612 ports
;part 1
ym2612a0 			equ &4000
ym2612d0			equ &4001
;part 2
ym2612a1			equ &4002
ym2612d1			equ &4003

; Constants for VGM file format
vgm_data_ptr_offset		equ &34
vgm_sample_rate			equ 44100 ;samples per second
vgm_samples_per_frame		equ 735

vgm_cmd_2612port0		equ &52
vgm_cmd_2612port1		equ &53

vgm_cmd_psg			equ &50

vgm_cmd_eof			equ &66

; Waits are in SAMPLES, not frames
vgm_cmd_wait_n			equ &61
vgm_cmd_wait_735		equ &62
vgm_cmd_wait_882		equ &63

; Adds 8bit value of a into the 16bit value of HL (little endian)
macro AddAHL	offset
	add 	a, l
	ld 	l, a
	adc 	a, h
	sub 	l
	ld 	h, a
mend

macro AddHL	offset
	ld	a, offset
	AddAHL
mend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; YM2612 Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro	WaitYM2612
	nop
	nop
mend

macro	SetYM2612_p0	addr, data
	ld	a, addr
	ld	(ym2612a0), a
	WaitYM2612
	ld	a, data
	ld	(ym2612d0), a
	WaitYM2612
mend

start:
	org &0000
	di
	jp init



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Some variables to take up space before int handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfx_counter		db 0
sfx_bgm_counter		db 0

;bit 0 - playing melody
;bit 1 - music waiting x frames
;bit 2 - music should repeat
sfx_state		db 0
			ds 1

sfx_callback:		dw sfx_nop	; Callback for sound fx

sfx_music_addr		dw 0		; Beginning addr of current sound file - should be set to valid address if state includes bgm playback
sfx_music_data		dw 0		; Where to read the actual data for the song. Advances with song.

sfx_YM216_mute_targets:	db 0
			db 1
			db 2
			db 4
			db 5
			db 6

align 2

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
	jp	sfx_return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; V Int Handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align	&38
vblank:	
	push    af
        push    de
        push    hl

	ld	hl, sfx_bgm_counter
	dec	(hl)			; count backwards to check against 0

	ld	a, (sfx_state)
	bit 	0, a
	jp	NZ, continue_bgm
	bgm_return:

	ld	hl, sfx_counter
	dec	(hl)

	ld	hl, (sfx_callback)
	jp	(hl)
	sfx_return:
	
	pop	hl
	pop	de
	pop	af
	ei
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Silence the YM2612 - Key Off on all channels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfx_mute_YM2612:
	ld	hl, sfx_YM216_mute_targets
	ld	b, 6
	sfx_mute_YM2612_loop:
		ld	a, &28
		ld	(ym2612a0), a
		WaitYM2612
		ld	a, (hl)
		ld	(ym2612d0), a
		WaitYM2612
		inc	hl
		djnz 	sfx_mute_YM2612_loop
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets state to play BGM without repetition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bgm_norepeat:
	ld	a, (sfx_state)
	set	0, a
	res 	2, a
	res	1, a
	ld	(sfx_state), a
	call	prepare_bgm
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sets state to play BGM with repetition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bgm_repeat:
	ld	a, (sfx_state)
	set	0, a
	set 	2, a
	res	1, a
	ld	(sfx_state), a
	call	prepare_bgm
	ret

init:	
	im 	1
	ld 	sp, &2000

	call sfx_mute_psg
	call sfx_mute_YM2612
	ei

endlessloop: 				
	; sfx advancement happens on vblank
	; this just keeps the CPU occupied
	jr endlessloop

prepare_bgm:
	; setup song data ptr
	call	sfx_mute_YM2612

	ld 	hl, (sfx_music_addr)
	AddHL	vgm_data_ptr_offset
	push	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	add	hl, bc
	ld	(sfx_music_data), hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BGM Playback loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
continue_bgm:
	;a still has sfx_state
	bit	1, a						; check if waiting
	jr	Z, bgm_data_scan

	ld	a, (sfx_bgm_counter)
	or	a
	jp	NZ, bgm_return

	ld	a, (sfx_state)					; Clear waiting flag
	res	1, a
	ld	(sfx_state), a

bgm_data_scan:
	ld	hl, (sfx_music_data)
	ld	a, (hl)
	inc	hl
	
	;if/else block to react to supported commands
	;if space allows, a table might be faster

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; WAIT N SAMPLES - CONVERT TO FRAMES
	; Not accurate but "Good enough"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cp	vgm_cmd_wait_n
	jr	NZ, vgm_cmd_wait_n_checked
	; Take the "high" byte and then halve to approximate the # of frames to skip
	inc	hl
	ld	a, (hl)
	srl	a
	ld	(sfx_bgm_counter), a

	inc	hl
	ld	(sfx_music_data), hl

	ld	a, (sfx_state)					; set waiting flag
	set	1, a
	ld	(sfx_state), a
	jp	bgm_return
	vgm_cmd_wait_n_checked:


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; YM2612 DATA
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cp	vgm_cmd_2612port0
	jr	NZ, vgm_cmd_2612port0_checked
	ld	a, (hl)
	ld	(ym2612a0), a
	WaitYM2612
	inc	hl
	ld	a, (hl)
	ld	(ym2612d0), a
	WaitYM2612
	inc	hl
	ld	(sfx_music_data), hl
	jp	bgm_data_scan
	vgm_cmd_2612port0_checked:

	cp	vgm_cmd_2612port1
	jr	NZ, vgm_cmd_2612port1_checked
	ld	a, (hl)
	ld	(ym2612a1), a
	WaitYM2612
	inc	hl
	ld	a, (hl)
	ld	(ym2612d1), a
	WaitYM2612
	inc	hl
	ld	(sfx_music_data), hl
	jp	bgm_data_scan
	vgm_cmd_2612port1_checked:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; PSG
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; (PSG tones are not supported to make it easier for sound effects...)
	; maybe in the future I will use a priority queue
	cp	vgm_cmd_psg
	jr	NZ, vgm_cmd_psg_checked
	inc	hl
	ld	(sfx_music_data), hl
	jp	bgm_data_scan
	vgm_cmd_psg_checked:
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; EOF - Clear "playing melody" flag
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cp	vgm_cmd_eof
	jr	NZ, vgm_cmd_eof_checked
	; 	Check if melody is supposed to repeat or not
	ld	a, (sfx_state)
	bit	2, a
	jr	NZ, bgm_eof_repeat
	res	0, a
	ld	(sfx_state), a	
	call	sfx_mute_YM2612
	jp	bgm_return
	bgm_eof_repeat:
	call	NZ, prepare_bgm	; Loop if the "melody repeat" bit is set
	jp	bgm_return
	vgm_cmd_eof_checked:

	; anything else is unsupported and hopefully not in the file...
	; Halt here for debugging ;)
	ld	bc, 255
	halt
	jp	bgm_return

;For sanity, make sure this driver is 16bit aligned
align 2
sfx_driver_end: