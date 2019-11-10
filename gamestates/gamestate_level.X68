; Controls
control_jump            EQU joypad_c

; Note on velocity - it is by a factor of 8
; so this means that gravity is actually at 1/4 pixel per frame per frame
world_gravity           EQU $02
; for states in RAM, not VRAM
sprite_flip_h           EQU $00
sprite_jumping          EQU $01
sprite_falling          EQU $02

sprite_airborne         EQU $06             ; bits 2 and 1


player_height           EQU $40             ; 64 pixels tall
player_x_speed          EQU $02

player_jump_strength    EQU -$20

player_jump_duration    EQU $18             ; number of frames the player can hold jump to jump higher



camera_zone_width       EQU $30
camera_zone_height      EQU $60

camera_zone_hmin        EQU (vdp_screen_width>>1)-(camera_zone_width>>1)
camera_zone_hmax        EQU (vdp_screen_width>>1)+(camera_zone_width>>1)

camera_zone_vmin        EQU (vdp_screen_height>>1)-(camera_zone_height>>1)
camera_zone_vmax        EQU (vdp_screen_height>>1)+(camera_zone_height>>1)

; a1 always pointed to the start of the level we're working with

Init_Level:
    move.w	#interrupts_disable, sr
    move.w  #0, (frame_counter)
    ClearVram

    * - a1 level
    * - a2 tileset
    * - a3 palettes
    moveq   #0, d0
    move.l  a2, a0
    move.w  d1, d0
    bsr.w   LoadTiles

    move.l  a3, a0
    moveq   #2, d0
	bsr.w   LoadPalettes

    ; first long in level data is the address of player start
    move.l  (a1)+, a6
    move.l  (a6),  d0
    move.l  d0, (MEM_player_pos)


    ; Move camera to upper left of camera box
    move.l  d0, d5
    move.l  a1, a0
    ClampCameraToPlayer d5, d0
    ClampCameraToLevel  d5, d2, d3
    move.l  d5, (MEM_camera_pos)

    ; a0 now points to the start of level data
    move.l  a1, a0
    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2                       ; Level Height
    move.w  (a0)+, d3                       ; Level Width


    ; Rough way of filling the frame with the right tiles given our starting scroll
    ; Start with moving into our data based on the camera offset
    moveq   #0, d0
    swap    d5
    move.w  d5, d0
    lsr.w   #3, d0
    mulu.w  d3, d0

    swap    d5
    move.w  d5, d1
    lsr.w   #3, d1
    add.w   d1, d0
    add.l   d0, d0
    add.l   d0, a0

    sub.w   #vdp_visible_tile_width,   d3                   ; difference between level width and plane width
    add.l   d3, d3                                          ; tiles * 2 byte offset to skip rows in the level data

    ; Then camera offset will be used to determine where in VRAM we write to
    lsr.w   #3, d5
    swap    d5
    lsr.w   #3, d5

    move.w  #vdp_visible_tile_height-1, d1
    fill_frame_y:
        move.w  #vdp_visible_tile_height-1, d6
        sub.w   d1, d6
        add.w   d5, d6
        andi.w  #vdp_plane_tile_height-1, d6
        lsl.w   #6, d6

        swap    d5
        move.w  #vdp_visible_tile_width-1, d0
        fill_frame_x:
            moveq   #0, d7
            move.w  d6, d7

            move.w  #vdp_visible_tile_width-1, d4
            sub.w   d0, d4
            add.w   d5, d4
            andi.w  #vdp_plane_tile_width-1, d4

            add.w   d4, d7
            add.w   d7, d7
            swap    d7
            addi.l  #vdp_write_plane_a, d7
            move.l  d7, vdp_control
            move.w  (a0)+, vdp_data
            dbra    d0, fill_frame_x

        add.l   d3, a0
        swap    d5
        dbra    d1, fill_frame_y




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

    *---------------------------------------------------------------------------------
    * Jumping / falling - a jump input will be processed on the next frame!
    *---------------------------------------------------------------------------------
    moveq   #0, d0                                      ; Add gravity to velocity
    move.b  (MEM_player_state), d6

    swap    d1

    ;   velocity is at a factor of 8 for subpixel precision
    move.w  (MEM_player_velocity_y), d0
    * bpl.s   vel_y_positive
    *     neg     d0
    *     subi.w  #world_gravity, d0
    *     move.w  d0, d4
    *     lsr.w   #3, d4
    *     sub.w   d4, d1
    *     neg     d0
    *     bra.s   vel_y_adjusted
    *     vel_y_positive:
    *     addi.w  #world_gravity, d0
    *     move.w  d0, d4
    *     lsr.w   #3, d4
    *     add.w   d4, d1
    * vel_y_adjusted:

    ; check d1 against level
    * move.l  a1, a0
    * move.w  (a0)+, d3                            ; d3 has level height
    * moveq   #0, d4
    * move.w  (a0)+, d4                            ; d4 has level width
    * ; determine offset into level data
    * move.w  d1, d7
    * lsr.w   #3, d7
    * mulu.w  d7, d4

    * swap    d1
    * move.w  d1, d5
    * swap    d1
    * lsr.w   #3, d5
    * add.w   d5, d4
    
    * add.w   d4, d4
    * add.l   d4, a0

    * move.w  (a0), d4

    * tst.w   d4
    * beq.s   lvl_player_feet_bounds             ; clear all "jump" flags to let player jump again
    *     move.w  d5, d3
    *     lvl_player_feet_bounds:
    *     asl.w   #3, d4
    * *     lvl_adjust_player_feet:
    *     subi.w  #player_height, d4
    *     cmp.w   d4, d1
    *     blt.s   lvl_checked_player_feet             ; Player has landed - clear all "jump" flags to let the player jump again
    *         move.w  d4, d1
    *         move.b  #0, (MEM_player_jump_frames)
    *         bclr    #sprite_jumping, d6
    *         move.b  d6, (MEM_player_state)
    *         moveq   #0, d0
    * lvl_checked_player_feet:

    move.w  d0, (MEM_player_velocity_y)
    swap    d1

    *********************************************************************************************
    * INPUT... INPUT!!!
    *********************************************************************************************
    move.b	(MEM_buttons_held), d0

    move.b  d0, d7
    andi.b  #joypad_right, d7
    beq.s   lvl_check_left              ; Not pressing right; see if pressing left
        ; Moving RIGHT
        ClearFlipH    (MEM_player_state)
        addi.w  #player_x_speed, d1
        bra.s   lvl_lr_checked
    lvl_check_left:
        move.b	d0, d7
        andi.b  #joypad_left, d7
        beq.s   lvl_lr_checked
            ; Moving LEFT
            SetFlipH    (MEM_player_state)
            subi.w  #player_x_speed, d1
    lvl_lr_checked:

    * ; check up/down - No more flying rabbits!
    swap    d1
    move.b  d0, d7
    andi.b  #joypad_down, d7
    beq.s   lvl_check_up              
        ; Moving RIGHT
        addi.w  #player_x_speed, d1
        bra.s   lvl_ud_checked
        move.w  #0, (MEM_player_velocity_y)
    lvl_check_up:
        move.b	d0, d7
        andi.b  #joypad_up, d7
        beq.s   lvl_ud_checked
            ; Moving LEFT
            subi.w  #player_x_speed, d1
            move.w  #0, (MEM_player_velocity_y)
    lvl_ud_checked:
    swap    d1

    move.l  d1, (MEM_player_pos)

    ; Move the camera as needed
    move.l  a1, a0
    ClampCameraToPlayer d2, d1
    ClampCameraToLevel  d2, d6, d7

    move.l  (MEM_camera_pos),  d5       ; keep previous camera position as a reference in d5
    move.l  d2, (MEM_camera_pos)

    ; prepare to stream from the edges
    StreamLevelForCamera


    * move.b	(MEM_buttons_held), d0
    * move.b  d0, d7
    * andi.b  #joypad_right, d7
    * beq.w   lvl_check_left              ; Not pressing right; see if pressing left
    *---------------------------------------------------------------------------------
    * Moving Right
    *---------------------------------------------------------------------------------
    *     move.b  (MEM_player_state), d6
    *     bclr    #sprite_flip_h, d6
    *     move.b  d6, (MEM_player_state)
    *     addi.w  #player_x_speed, d1
        
    *     ; Move camera if we are far enough to the right
    *     move.w  d1, d7
    *     sub.w   #camera_zone_hmax, d7
    *     cmp.w   d2, d7
    *     ble.w   lvl_lr_checked
    *     move.w  d7, d2

    *     ; It might be better to make levels with "borders" rather than do this check...
    *     move.l  (a1), d0
    *     asl.w   #3, d0
    *     subi.w  #320, d0            ; 320 pixels from camera start to the end of the frame - do not let camera go past level
    *     cmp.w   d0, d2
    *     ble.s   lvlcam_clamp_max
    *     move.w  d0, d2
    *     lvlcam_clamp_max:

    *     ;Stream level into view from the right
    *     StreamLevel #vdp_plane_vis_byte_w
    *     bra.w   lvl_lr_checked
    * lvl_check_left:
    *     move.b	d0, d7
    *     andi.b  #joypad_left, d7
    *     beq.w   lvl_lr_checked
    *     *---------------------------------------------------------------------------------
    *     * Moving Left
    *     *---------------------------------------------------------------------------------
    *         move.b  (MEM_player_state), d6
    *         bset    #sprite_flip_h, d6
    *         move.b  d6, (MEM_player_state)

    *         subi.w  #player_x_speed, d1

    *         ; Move camera if we are far enough to the left
    *         move.w  d1, d7
    *         sub.w   #camera_zone_hmin, d7
    *         cmp.w   d2, d7
    *         bge.s   lvl_lr_checked
    *         move.w  d7, d2

    *         btst    #$0F, d2            ; Limit range - assume if we are here, we are below zero
    *         beq.s   lvlcam_clamp_min
    *         move.w  #0, d2
    *         lvlcam_clamp_min:

    *         ;Stream level into view from the left
    *         StreamLevelLeft #vdp_plane_byte_width
    * lvl_lr_checked:


    *---------------------------------------------------------------------------------
    * And the club is jumpin', jumpin'
    *---------------------------------------------------------------------------------
    move.b  (MEM_player_state), d6
    btst    #sprite_jumping, d6
    beq.s   lvl_notjumping
        move.b	(MEM_buttons_held), d0
        andi.b  #control_jump, d0
        beq.s   lvl_player_jump_checked
            move.b  (MEM_player_jump_frames), d0
            cmp.b   #player_jump_duration, d0
            bge.s   lvl_player_jump_checked
                move.w  #player_jump_strength, (MEM_player_velocity_y)
                addq    #1, d0
                move.b  d0, (MEM_player_jump_frames)
                bra.s   lvl_player_jump_checked
    lvl_notjumping:
        move.b	(MEM_buttons_pressed), d0
        andi.b  #control_jump, d0
        beq.s   lvl_player_jump_checked
            bset    #sprite_jumping, d6
            move.w  #player_jump_strength, (MEM_player_velocity_y)
            move.b  #0, (MEM_player_jump_frames)
    lvl_player_jump_checked:

    move.b  d6, (MEM_player_state)


    * ---------------------------------------------------------------------------------
    * Scroll Planes Horizontally and vertically
    * ---------------------------------------------------------------------------------
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

    swap    d2
    move.w  d2, d7
    move.l  #vdp_vram_vscroll, vdp_control
    move.w  d7,   vdp_data
    move.w  #0, vdp_data
    swap    d2

    *-----------------------------------------------------------
    * Sprites
    *-----------------------------------------------------------
    ; Draw all the sprites - start with the player because players come first!
    ; Every sprite is world position + camera + {sprite_view_hmin,sprite_view_vmin}

    move.w	#interrupts_disable, sr                                     ; Disable interrupts

    lea     BaoLongTu_sprite_Idle0, a0
    moveq   #0,  d5
    move.w  #43, d5
    bsr.w   PushEmbeddedSpriteFrame

    move.l  #vdp_vram_sprite, vdp_control
    move.b  (MEM_player_state), d6
    bsr.w   DrawSpriteFrame

    move.w	#interrupts_enable, sr                                      ; re-enable interrupts

    EndLoop