player_x_speed          EQU $02

; a1 always pointed to the start of the level we're working with

Init_Level:
    move.w	#interrupts_disable, sr
    move.w  #0, (frame_counter)
    ClearVram

    move.l  a1, a0

    bsr.w   Level_FillFrame
    
    lea     Palettes_Mario11, a0
	moveq   #1, d0
	bsr.w   LoadPalettes
	
	lea     Tiles_Mario11, a0
	move.l  #64, d0
	bsr.w   LoadTiles

    ; We're off to the races!
    move.w	#interrupts_enable, sr
    rts
MainLoop_Level:
    move.l  (MEM_camera_pos),   d1                ; d1 holds the camera offset for entire frame


    move.l  d1, d6                                ; d6 holds a copy so we can see the delta
    move.b	(MEM_buttons_held), d0

    move.b  d0, d2
    andi.b  #joypad_right, d2
    beq.s   lvl_check_left
    ; MOVING RIGHT
    addi.w  #player_x_speed, d1
    bra.s   lvl_lr_checked
    lvl_check_left:
        move.b	d0, d2
        andi.b  #joypad_left, d2
        beq.s   lvl_lr_checked
        ; MOVING LEFT
        subi.w  #player_x_speed, d1    
    lvl_lr_checked:

    *-----------------------------------------------------------
    * Clamp Camera to level extents... makes everything simpler
    *-----------------------------------------------------------
    btst    #$0F, d1            ; Limit range - assume if we are here, we are below zero
    beq.s   lvlcam_clamp_min
    move.w  #0, d1
    bra.s   lvlcam_clamp_max
    lvlcam_clamp_min:
    move.w  (a1), d0
    andi.w  #$00FF, d0
    asl.w   #3, d0
    subi.w  #320, d0            ; 320 pixels from camera start to the end of the frame
    cmp.w   d0, d1
    ble.s   lvlcam_clamp_max
    move.w  d0, d1
    lvlcam_clamp_max:

    *---------------------------------------------------------------------------------
    * Scroll Level Into view
    *---------------------------------------------------------------------------------
    cmp.w   d6, d1                              ; See if the camera moved at all
    beq.w   lvl_stream_end
    bgt.s   lvl_stream_right

    StreamLevelLeft #vdp_plane_byte_width
    bra.s   lvl_stream_end

    lvl_stream_right:
        StreamLevel #vdp_plane_vis_byte_w

    lvl_stream_end:

    *---------------------------------------------------------------------------------
    * Scroll Level H
    *---------------------------------------------------------------------------------
    moveq   #0, d0                              ; d0 will loop for every h
    move.b  #vdp_screen_height, d0
    move.l  #vdp_vram_hscroll, vdp_control
    move.w  d1, d2      
    neg     d2                                  ; scroll against camera
    lvl_scroll_loop:
        move.w  d2, vdp_data
        move.w  #0, vdp_data
        dbra    d0, lvl_scroll_loop

    move.l  d1, (MEM_camera_pos)

    EndLoop