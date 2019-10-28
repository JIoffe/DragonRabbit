player_x_speed          EQU $02

camera_zone_width       EQU $30
camera_zone_hmin        EQU (vdp_screen_width>>1)-(camera_zone_width>>1)
camera_zone_hmax        EQU (vdp_screen_width>>1)+(camera_zone_width>>1)

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

    lea     BaoLongTu_sprite_Idle0, a0
    move.w  #64, d1
    bsr.w   PushEmbeddedSpriteFrame

    move.l  #$00000000, (MEM_player_pos)

    ; We're off to the races!
    move.w	#interrupts_enable, sr
    rts
MainLoop_Level:

    ; This implies the camera ONLY moves with input, might need
    ; to refactor or add on to this to support things like moving platforms.

    ; d1 will hold the player's position for the entire frame
    move.l  (MEM_player_pos),   d1
    ; Move the camera along with the player - d2 holds the camera for the majority of the frame
    move.l  (MEM_camera_pos),   d2

    move.b	(MEM_buttons_held), d0
    move.b  d0, d7
    andi.b  #joypad_right, d7
    beq.s   lvl_check_left              ; Not pressing right; see if pressing left
    *---------------------------------------------------------------------------------
    * Moving Right
    *---------------------------------------------------------------------------------
        addi.w  #player_x_speed, d1
        
        ; Move camera if we are far enough to the right
        move.w  d1, d7
        sub.w   #camera_zone_hmax, d7
        cmp.w   d2, d7
        ble.w   lvl_lr_checked
        move.w  d7, d2

        ; It might be better to make levels with "borders" rather than do this check...
        move.l  (a1), d0
        asl.w   #3, d0
        subi.w  #320, d0            ; 320 pixels from camera start to the end of the frame - do not let camera go past level
        cmp.w   d0, d2
        ble.s   lvlcam_clamp_max
        move.w  d0, d2
        lvlcam_clamp_max:

        ;Stream level into view from the right
        StreamLevel #vdp_plane_vis_byte_w
        bra.s   lvl_lr_checked
    lvl_check_left:
        move.b	d0, d7
        andi.b  #joypad_left, d7
        beq.s   lvl_lr_checked
        *---------------------------------------------------------------------------------
        * Moving Left
        *---------------------------------------------------------------------------------
            subi.w  #player_x_speed, d1

            ; Move camera if we are far enough to the left
            move.w  d1, d7
            sub.w   #camera_zone_hmin, d7
            cmp.w   d2, d7
            bge.s   lvl_lr_checked
            move.w  d7, d2

            btst    #$0F, d2            ; Limit range - assume if we are here, we are below zero
            beq.s   lvlcam_clamp_min
            move.w  #0, d2
            lvlcam_clamp_min:

            ;Stream level into view from the left
            StreamLevelLeft #vdp_plane_byte_width
    lvl_lr_checked:

    ; Save latest player position
    move.l  d1, (MEM_player_pos)

    *---------------------------------------------------------------------------------
    * Scroll Planes Horizontally
    *---------------------------------------------------------------------------------
    moveq   #0, d0                              ; d0 will loop for every h
    moveq   #0, d7
    move.b  #vdp_screen_height, d0
    move.l  #vdp_vram_hscroll, vdp_control
    move.w  d2, d7      
    neg     d7                                  ; scroll against camera
    lvl_scroll_loop:
        move.w  d7, vdp_data
        move.w  #0, vdp_data
        dbra    d0, lvl_scroll_loop

    move.l  d2, (MEM_camera_pos)

    *-----------------------------------------------------------
    * Sprites
    *-----------------------------------------------------------
    ; Draw all the sprites - start with the player because players come first!
    ; Every sprite is world position + camera + {sprite_view_hmin,sprite_view_vmin}
    move.l  #vdp_vram_sprite, vdp_control

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_vmin, d1
    move.w  d1,  vdp_data

    move.w  #$0700,  vdp_data
    move.w  #65,  vdp_data

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_hmin, d1
    move.w  d1,  vdp_data

    EndLoop