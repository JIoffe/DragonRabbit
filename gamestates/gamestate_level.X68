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


player_height           EQU $40
player_width            EQU $28
player_width_tiles      EQU (player_width>>3)
player_width_tbytes     EQU (player_width_tiles<<1)
player_x_speed          EQU $02

player_jump_strength    EQU -$20

player_jump_duration    EQU $18             ; number of frames the player can hold jump to jump higher



camera_zone_width       EQU $30
camera_zone_height      EQU $54

camera_zone_hmin        EQU (vdp_screen_width>>1)-(camera_zone_width>>1)
camera_zone_hmax        EQU (vdp_screen_width>>1)+(camera_zone_width>>1)

camera_zone_vmin        EQU (vdp_screen_height>>1)-(camera_zone_height>>1)-(player_height>>1)
camera_zone_vmax        EQU (vdp_screen_height>>1)+(camera_zone_height>>1)-player_height

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
    moveq   #3, d0
	bsr.w   LoadPalettes

    ; Setup background - this will vary by level somehow
    moveq   #3, d4
    testroombg_loop:
        move.l  #vdp_write_plane_b, a5
        moveq   #0, d5
        move.w  d4, d5
        asl.w   #4, d5
        or.w    #$0600, d5
        swap    d5
        lea     TESTROOM_BG, a0
        bsr.w   Plane_DrawPattern
        dbra    d4, testroombg_loop

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

    sub.w   #vdp_plane_tile_width, d3                   ; difference between level width and plane width
    add.l   d3, d3                                      ; tiles * 2 byte offset to skip rows in the level data

    ; Then camera offset will be used to determine where in VRAM we write to
    lsr.w   #3, d5
    swap    d5
    lsr.w   #3, d5

    move.w  #vdp_plane_tile_height-1, d1
    fill_frame_y:
        move.w  #vdp_plane_tile_width-1, d6
        sub.w   d1, d6
        add.w   d5, d6
        andi.w  #vdp_plane_tile_height-1, d6
        lsl.w   #6, d6

        swap    d5
        move.w  #vdp_plane_tile_width-1, d0
        fill_frame_x:
            moveq   #0, d7

            move.w  #vdp_plane_tile_width-1, d7
            sub.w   d0, d7
            add.w   d5, d7
            andi.w  #vdp_plane_tile_width-1, d7
            add.w   d6, d7
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
    move.w	#interrupts_disable, sr                                     ; Disable interrupts

    ; This implies the camera ONLY moves with input, might need
    ; to refactor or add on to this to support things like moving platforms.

    ; d1 will hold the player's position for the entire frame
    move.l  (MEM_player_pos),   d1

    *---------------------------------------------------------------------------------
    * Jumping / falling - a jump input will be processed on the next frame!
    *---------------------------------------------------------------------------------
    moveq   #0, d0                                      ; Add gravity to velocity
    swap    d1
    move.w  d1, d6                              ; let d6 hold the potential next position

    ;   velocity is at a factor of 8 for subpixel precision (if it's stupid but it works...)
    move.w  (MEM_player_velocity_y), d0
    bpl.s   vel_y_positive
        neg     d0
        subi.w  #world_gravity, d0
        move.w  d0, d4
        lsr.w   #3, d4
        sub.w   d4, d6
        neg     d0
        bra.s   vel_y_adjusted
        vel_y_positive:
            addi.w  #world_gravity, d0
            move.w  d0, d4
            lsr.w   #3, d4
            add.w   d4, d6
    vel_y_adjusted:

    * ; see if player has dropped beneath tiles
    * ; ray march for every row the player has dropped

    move.l  a1, a0
    move.w  (a0)+, d3                            ; d3 has level height
    moveq   #0, d4
    move.w  (a0)+, d4                            ; d4 has level width

    cmp.w   d1, d6
    bpl.s   lvl_player_falling
        bra.s   lvl_player_y_adjusted
    lvl_player_falling:
        move.w  d1, d2
        add.w   #player_height, d2
        lsr.w   #3, d2

        move.w  d6, d7
        add.w   #player_height, d7
        lsr.w   #3, d7
        swap    d7
        swap    d1       
        move.w  d1, d7
        lsr.w   #3, d7
        swap    d7
        swap    d1
        lvl_player_falling_scan:
            move.l  a0, a2

            ; see tile at index
            moveq   #0, d5
            move.w  d2, d5
            mulu.w  d4, d5

            swap    d7
            add.w   d7, d5
            add.w   d5, d5
            add.l   d5, a2

            tst.w   (a2)
            beq.s   lvl_fall_scan_check_lr
            lvl_fall_scan_hit:
                move.w  d2, d6
                asl.w   #3, d6
                subi.w  #player_height, d6
                bra.s   lvl_player_landed
            lvl_fall_scan_check_middle:
                add.w   #player_width_tiles, a2
                tst.w   (a2)
                bne.s   lvl_fall_scan_hit
            lvl_fall_scan_check_lr:
                add.w   #player_width_tiles, a2
                tst.w   (a2)
                bne.s   lvl_fall_scan_hit

            lvl_fall_scan_continue:
            addq    #1, d2
            swap    d7
            cmp.w   d7, d2
            ble.s   lvl_player_falling_scan

        asl.w   #3, d3
        subi.w  #player_height, d3
        cmp.w   d3, d6
        blt.s   lvl_player_y_adjusted
            move.w  d3, d6
        lvl_player_landed:
            move.b  #0, (MEM_player_jump_frames)
            move.b  (MEM_player_state), d7
            bclr    #sprite_jumping, d7
            move.b  d7, (MEM_player_state)
            moveq   #0, d0
    lvl_player_y_adjusted:
    move.w  d0, (MEM_player_velocity_y)
    move.w  d6, d1
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

    ; Move the camera along with the player - d2 holds the camera for the majority of the frame
    move.l  (MEM_camera_pos),   d2
    ClampCameraToPlayer d2, d1
    ClampCameraToLevel  d2, d6, d7

    move.l  (MEM_camera_pos),  d5       ; keep previous camera position as a reference in d5
    move.l  d2, (MEM_camera_pos)

    ; prepare to stream from the edges
    StreamLevelForCamera


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

    ; this will vary by level neatly somehow...
    ; always assume d2 is the camera
    moveq   #0, d0                              ; d0 will loop for every h
    moveq   #0, d7

    move.l  #vdp_vram_hscroll, vdp_control
    move.w  d2, d7      
    neg     d7                                  ; scroll against camera

    move.b  #47, d0
    lvl_scroll_loop_a:
        move.w  d7, vdp_data
        move.w  #0, vdp_data
        dbra    d0, lvl_scroll_loop_a

    moveq   #0, d0
    move.b  #32, d0
    move.w  d7, d6
    lsr.w   #1, d6
    lvl_scroll_loop_b:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_b

    moveq   #0, d0
    move.b  #16, d0
    lsr.w   #1, d6
    lvl_scroll_loop_c:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_c

    moveq   #0, d0
    move.b  #12, d0
    lsr.w   #1, d6
    lvl_scroll_loop_d:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_d

    moveq   #0, d0
    move.b  #25, d0
    lsr.w   #1, d6
    lvl_scroll_loop_e:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_e

    moveq   #0, d0
    move.b  #30, d0
    lsr.w   #1, d6
    lvl_scroll_loop_f:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_f

    ; Grass to trees
    moveq   #0, d0
    move.b  #7, d0
    move.w  d7, d6
    lsr.w   #4, d6
    lvl_scroll_loop_g:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_g

    moveq   #0, d0
    move.b  #7, d0
    move.w  d7, d6
    lsr.w   #3, d6
    lvl_scroll_loop_h:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_h

    moveq   #0, d0
    move.b  #7, d0
    move.w  d7, d6
    lsr.w   #2, d6
    lvl_scroll_loop_i:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_i

    moveq   #0, d0
    move.b  #31, d0
    move.w  d7, d6
    lsr.w   #1, d6
    lvl_scroll_loop_j:
        move.w  d7, vdp_data
        move.w  d6, vdp_data
        dbra    d0, lvl_scroll_loop_j

    swap    d2
    move.w  d2, d7
    move.l  #vdp_vram_vscroll, vdp_control
    move.w  d7,   vdp_data
    move.w  #0, vdp_data
    swap    d2                                  ; swap the camera because we'll be using it for sprites

    *-----------------------------------------------------------
    * Sprites
    *-----------------------------------------------------------
    ; Draw all the sprites - start with the player because players come first!
    ; Every sprite is world position + camera + {sprite_view_hmin,sprite_view_vmin}

    moveq   #1, d4                              ; d4 will keep track of *linking*

    lea     BaoLongTu_sprite_Idle0, a0
    moveq   #0,  d5
    move.w  (MEM_player_sprite_start), d5
    bsr.w   PushEmbeddedSpriteFrame

    move.l  #vdp_vram_sprite, vdp_control
    move.b  (MEM_player_state), d6
    bsr.w   DrawSpriteFrame

    ; Cap off with a blank sprite (lazy but works I hope)
    move.l  #0, vdp_data
    move.l  #0, vdp_data

    move.w	#interrupts_enable, sr                                      ; re-enable interrupts

    EndLoop