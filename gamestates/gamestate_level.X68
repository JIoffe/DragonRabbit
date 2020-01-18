; Controls
control_jump            EQU joypad_c
control_attack          EQU joypad_a

; Note on velocity - it is by a factor of 8
; so this means that gravity is actually at 1/4 pixel per frame per frame
world_gravity           EQU $02
; for states in RAM, not VRAM
sprite_flip_h           EQU $00
sprite_jumping          EQU $01
sprite_falling          EQU $02

sprite_airborne         EQU $06             ; bits 2 and 1



camera_zone_width       EQU $30
camera_zone_height      EQU $54

camera_zone_hmin        EQU (vdp_screen_width>>1)-(camera_zone_width>>1)-(player_width>>1)
camera_zone_hmax        EQU (vdp_screen_width>>1)+(camera_zone_width>>1)-(player_width>>1)

camera_zone_vmin        EQU (vdp_screen_height>>1)-(camera_zone_height>>1)-(player_height>>1)
camera_zone_vmax        EQU (vdp_screen_height>>1)+(camera_zone_height>>1)-player_height

camera_zone_bb_start    EQU (camera_zone_vmin<<16)|camera_zone_hmin
camera_zone_bb_offset   EQU (camera_zone_height<<16)|camera_zone_width

lvl_fadein_interval     EQU $03

; a1 always pointed to the start of the level we're working with
Init_Level:
    move.w	#interrupts_disable, sr
    DisableHBlank
    jsr     ResetState
    bsr.w   ClearLevelVars

    move.b  #$0E, (MEM_fade)              ; Start at full fade and then fade in
    move.l  a3, (MEM_palette)

    * d1 and d2 should already hold the correct values for DMA
    move.w  d1, d5
    move.l  #$20, d3
    jsr     TriggerDMADumpToVRAM
    

    add.w   d5, d5
    addi.w  #$20, d5
    move.w  d5, MEM_player_tiles_start         ; VRAM address where to DMA player tiles into
    lsr.w   #5, d5
    move.w  d5, MEM_player_sprite_index

    addi.w  #player_tile_allocation, d5
    move.w  d5, (MEM_UI_sprite_start)

    addi.w  #score_vram_tile_offset, d5
    move.w  d5, (MEM_score_digits_id)
    lsl.w   #5, d5
    move.w  d5, (MEM_score_vram_address)

    bsr.w   LoadCoreGfx
    moveq   #0, d7
    bsr.w   CacheScoreSprites
    moveq   #0, d7
    bsr.w   CacheHealthSprite

    moveq   #3, d4
    ; Setup background - this will vary by level somehow
    testroombg_loop:
        move.l  #vdp_write_plane_b, a5
        moveq   #0, d5
        move.w  d4, d5
        asl.w   #4, d5
        or.w    #$0600, d5
        swap    d5
        lea     TestRoom_BG, a0
        bsr.w   Plane_DrawPattern
        dbra    d4, testroombg_loop

    ********************************************************
    * Parse active level
    ********************************************************
    ; first long in level data is the address of player start
    movea.l (a1)+, a2
    move.l  (a2),  d0
    move.l  d0, (MEM_player_pos)

    ; second long is the address of where items are held
    movea.l (a1)+, a2
    move.w  (a2)+, d0
    move.w  d0, (MEM_LEVELITEM_COUNT)
    lea.l   MEM_LEVELITEMS, a4
    lvl_copy_items_to_ram:
        move.w  (a2)+, (a4)+
        move.l  (a2)+, (a4)+
        dbra    d0, lvl_copy_items_to_ram


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
    
    ; Set "score dirty" flag so it will be redrawn on the first frame
    move.l  #BaoLongTu_sprite_Idle0, (MEM_player_previous_frame)
    bset    #score_changed, frame_state

    ; Naked and vulnerable
    SetPlayerVulnerable
    move.b  #player_max_hp, MEM_player_hp

    ; Set up vblank to DMA what we need
    move.b  #7, MEM_vblank_mode

    ; We're off to the races!
    move.w	#interrupts_enable, sr
    rts

Fadeout_Level:
    move.w  (frame_counter), d5
    moveq   #0, d1
    move.b  (MEM_fade), d1

    cmp.b   #$0E, d1
    beq.s   lvl_fadeout_advance
    andi.w  #lvl_fadein_interval, d5
    bne.s   lvl_fadeout_advance
        addi.b  #2, d1
        move.b  d1, (MEM_fade)
    lvl_fadeout_advance:

    move.l  MEM_palette, a0
    moveq   #4, d0
	bsr.w   FadePalettes

    move.w  (frame_counter), d5
    cmp.w   #88, d5
    bcs.s   continue_lvl_fadeout
        RestartLevel
    continue_lvl_fadeout:

    EndLoop

Fadein_Level:
    move.w  (frame_counter), d5
    moveq   #0, d1
    move.b  (MEM_fade), d1

    andi.w  #lvl_fadein_interval, d5
    bne.s   lvl_fadein_advance
        subi.b  #2, d1
        move.b  d1, (MEM_fade)
    lvl_fadein_advance:

    move.l  (MEM_palette), a0
    moveq   #4, d0
	bsr.w   FadePalettes

    tst.b   d1
    bne.s   lvl_continuefadein
        lea     MainLoop_Level, a6                              ; fade-in complete, just go through the usual level logic
        move.l  (MEM_palette), a0
        moveq   #4, d0
        bsr.w   LoadPalettes                                    ; make sure the palette is actually correct
    lvl_continuefadein:

    bra.s   MainLoop_Level
MainLoop_Level_PlayerDead:
    ; Restart the level when player is beyond view
    move.l  (MEM_player_pos),   d1
    move.l  (MEM_camera_pos),   d2

    swap    d1
    swap    d2
    sub.w   d2, d1
    subi.w  #vdp_screen_height, d1
    bmi.s   skip_death_restart
        move.b  #0, MEM_fade
        move.w  #0, frame_counter 
        lea     Fadeout_Level, a6
    skip_death_restart:
MainLoop_Level:
    bsr.w   PauseGame
    
    ; d1 will hold the player's position for the entire frame
    move.l  (MEM_player_pos),   d1
    move.w  d1, d6

    *********************************************************************************************
    * INPUT... INPUT!!!
    *********************************************************************************************
    move.b  (MEM_player_vulnerability), d0
    btst    #player_hurt_recoil, d0
    bne.w   skip_input

    btst    #player_dead, d0
    bne.w   skip_input

    move.b	(MEM_buttons_held), d0

    move.b  d0, d7
    andi.b  #joypad_right, d7
    beq.s   lvl_check_left              ; Not pressing right; see if pressing left
        ; Moving RIGHT
        ClearFlipH    (MEM_player_state), d2
        addi.w  #player_x_speed, d6
        bra.s   lvl_lr_checked
    lvl_check_left:
        move.b	d0, d7
        andi.b  #joypad_left, d7
        beq.s   lvl_lr_checked
            ; Moving LEFT
            SetFlipH    (MEM_player_state), d2
            subi.w  #player_x_speed, d6
    lvl_lr_checked:

    ; If player's trying to move, set the walking flag
    move.b  (MEM_player_state), d5
    cmp.w   d1, d6
    beq.s   lvl_not_walking
        bset    #player_walking, d5
        bra.s   lvl_walkingflag_set
    lvl_not_walking:
        bclr    #player_walking, d5
    lvl_walkingflag_set:
    move.b  d5, (MEM_player_state)

    skip_input:

    *******************************************************************
    * Player collision against level (horizontal)
    *******************************************************************
    move.l  a1, a0
    move.w  (a0)+, d3                            ; d3 has level height
    moveq   #0, d4
    move.w  (a0)+, d4                            ; d4 has level width

    moveq   #0, d0
    moveq   #0, d5

    move.w  d6, d2
    lsr.w   #3, d2   

    cmp.w   d1, d6
    blt.s   lvl_player_moving_left
        add.w   #player_width_tiles, d2     ; moving right - scan the right side
        lea     lvl_player_right_scan_hit, a3
        bra.s   lvl_side_prescan   ;player is moving right
    lvl_player_moving_left:
        lea     lvl_player_left_scan_hit, a3
        lvl_side_prescan:
        swap    d1
        move.w  d1, d5
        lsr.w   #3, d5
        swap    d1
        mulu.w  d4, d5

        add.w   d2, d5
        add.w   d5, d5
        add.l   d5, a0

        add.w   d4, d4
        move.w  #player_side_scan_height, d0
        lvl_side_scan:
            tst.w   (a0)
            bne.s   lvl_side_scan_hit
            add.l   d4, a0
            dbra    d0, lvl_side_scan
        bra.s  lvl_player_x_adjusted

    lvl_side_scan_hit:
        jmp     (a3)
    lvl_player_left_scan_hit:
        addq    #1, d2
        asl.w   #3, d2
        move.w  d2, d6
        bra.s   lvl_player_x_adjusted
    lvl_player_right_scan_hit:
        sub.w   #player_width_tiles, d2
        asl.w   #3, d2
        move.w  d2, d6

    lvl_player_x_adjusted:
    move.w  d6, d1                      ; update active player position


    *---------------------------------------------------------------------------------
    * VERTICAL VELOCITY: Jumping / falling
    *---------------------------------------------------------------------------------
    moveq   #0, d0                                      ; Add gravity to velocity
    swap    d1
    move.w  d1, d6                                      ; let d6 hold the potential next position

    ;   velocity is at a factor of 8 for subpixel precision (if it's stupid but it works...)
    move.w  (MEM_player_velocity_y), d0
    addi.w  #world_gravity, d0
    move.w  d0, d4
    asr.w   #3, d4
    add.w   d4, d6

    * *****************************************************************
    * * Kill player when falling past level bounds
    * *****************************************************************
    
    * bne.s   player_did_not_fall_to_doom
    *     KillPlayer
    * player_did_not_fall_to_doom:

    *****************************************************************
    * COLLIDE PLAYER AGAINST LEVEL TILES
    *****************************************************************
    * ; see if player has dropped beneath tiles
    * ; ray march for every row the player has dropped (The player can fall faster than moving side-to-side)

    SkipWhenPlayerDead  d3, lvl_player_y_adjusted

    move.l  a1, a0
    move.w  (a0)+, d3                            ; d3 has level height
    moveq   #0, d4
    move.w  (a0)+, d4                            ; d4 has level width

    cmp.w   d1, d6
    bpl.s   lvl_player_falling
        ; bump against ceiling tiles
        move.l  a0, a2
        move.w  d1, d2
        lsr.w   #3, d2
        mulu.w  d4, d2

        moveq   #0, d5
        swap    d1
        move.w  d1, d5
        swap    d1
        lsr.w   #3, d5

        add.w   d2, d5
        add.w   d5, d5
        add.l   d5, a2

        tst.w   (a2)
        bne.w   lvl_player_landed

        move.w  #player_width_tiles-1, d5
        add.w   d5, d5
        add.l   d5, a2

        tst.w   (a2)
        bne.w   lvl_player_landed

        bra.w   lvl_player_y_adjusted
    lvl_player_falling:
        asl.w   #3, d3
        subi.w  #player_height, d3
        cmp.w   d3, d6
        bcs.s   lvl_continue_fall_scan
            KillPlayer
            move.w  d3, d6
            bra.w   lvl_player_landed
        lvl_continue_fall_scan:

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
            bls.s   lvl_player_falling_scan
            bra.s   lvl_player_y_adjusted
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

    ************************************************************
    * SAVE PLAYER POSITION TO MEMORY
    ************************************************************
    move.l  d1, (MEM_player_pos)

    ; Move the camera as needed
    move.l  a1, a0

    ; Move the camera along with the player - d2 holds the camera for the majority of the frame
    move.l  (MEM_camera_pos),   d2

    SkipWhenPlayerDead  d5, camera_tracking_skip
    ClampCameraToPlayer d2, d1
    camera_tracking_skip:
    ClampCameraToLevel  d2, d6, d7

    move.l  (MEM_camera_pos),  d5       ; keep previous camera position as a reference in d5
    move.l  d2, (MEM_camera_pos)

    ; prepare to stream from the edges
    StreamLevelForCamera


    *---------------------------------------------------------------------------------
    * And the club is jumpin', jumpin'
    *---------------------------------------------------------------------------------
    move.b  (MEM_player_state), d6

    move.b  (MEM_player_vulnerability), d0
    btst    #player_hurt_recoil, d0
    bne.w   lvl_player_attack_checked

    btst    #player_dead, d0
    bne.w   lvl_player_attack_checked

    btst    #sprite_jumping, d6
    beq.s   lvl_notjumping
        move.b	(MEM_buttons_held), d0
        andi.b  #control_jump, d0
        beq.s   lvl_player_jump_checked
            move.b  (MEM_player_jump_frames), d0
            cmp.b   #player_jump_duration, d0
            bcc.s   lvl_player_jump_checked
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

    *----------------------------------------------------------------------------------
    * ATTACK!
    *----------------------------------------------------------------------------------
    move.b  (MEM_player_attack_frames), d5
    addq    #1, d5
    bvc.b   attack_frames_added                 ; clip so we don't see weird oddities on 0
    move.b  #$FF, d5
    attack_frames_added:

    cmp.b   #player_combo_time, d5
    bcs.s   lvl_player_combo_reset
        bclr    #player_attack_1, d6
        bclr    #player_attack_2, d6
        bclr    #player_attack_3, d6
    lvl_player_combo_reset:

    move.b  #0, (MEM_player_att_strength)                       ; clear the attack strength on each frame

    move.b	(MEM_buttons_pressed), d0
    andi.b  #control_attack, d0
    beq.w   lvl_player_attack_checked
        move.b  #1, (MEM_player_att_strength)                   ; to make it easier for now, all attacks will have 1 strength

        ; adjust the hitbox for player attack
        move.l  d1, d3
        btst    #sprite_flip_h, d6
        beq.s   lvl_player_attack_right
            subi.w  #player_attack_width, d3
            bra.s   lvl_player_att_hitbox_adjusted
            lvl_player_attack_right:
            addi.w  #player_width, d3
        lvl_player_att_hitbox_adjusted:
        move.l  d3, (MEM_playerattack_min)
        addi.l  #player_attack_bboffset, d3
        move.l  d3, (MEM_playerattack_max)

        ; in combo range, see  which round we're ready for
        btst    #player_attack_3, d6
        beq.s   player_combo2
            bclr    #player_attack_2, d6
            bclr    #player_attack_3, d6
            bset    #player_attack_1, d6
            move.b  #0, d5
            bra.s   lvl_player_attack_checked

        player_combo2:
        btst    #player_attack_2, d6
        beq.s   player_combo1
            bset    #player_attack_3, d6
            move.b  #0, d5
            bra.s   lvl_player_attack_checked
            
        player_combo1:
        btst    #player_attack_1, d6
        beq.s   player_combo0
            bset    #player_attack_2, d6
            move.b  #0, d5
            bra.s   lvl_player_attack_checked

        player_combo0:
        bset    #player_attack_1, d6
        move.b  #0, d5
    lvl_player_attack_checked:

    move.b  d6, (MEM_player_state)
    move.b  d5, (MEM_player_attack_frames)




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


    ; Has the great hero been injured?
    move.b  (MEM_player_state), d6
    move.b  (MEM_player_vulnerability), d0
    btst    #player_dead, d0
    beq.s   player_alive
        lea     BaoLongTu_sprite_Dead0, a0
        bra.w   lvl_player_animation_selected
    player_alive:
    btst    #player_hurt_recoil, d0
    beq.s   player_not_recovering
        lea     BaoLongTu_sprite_Hurt0, a0
        move.w  (MEM_player_inv_frames), d5
        bne.s   player_reduce_anguish
            ; End the anguish eventually
            bclr    #player_hurt_recoil, d0
            bset    #player_dmg_invulnerable, d0
            move.b  d0, (MEM_player_vulnerability)
            move.w  #player_dmg_inv_duration, d5
            move.w  d5, (MEM_player_inv_frames)
            bra.w   lvl_player_animation_selected
        player_reduce_anguish:
            subq    #1, d5
            move.w  d5, (MEM_player_inv_frames)
            bra.w   lvl_player_animation_selected
    player_not_recovering:
        ; Select animation based on player state
        test_attack_duration:
        move.b  (MEM_player_attack_frames), d0
        cmp.b   #player_attack_duration, d0
        bcc.s   lvl_player_notattacking
            ; choose player attack frame
            btst    #player_attack_3, d6
            beq.s   select_attack_2
                lea     BaoLongTu_sprite_Attack30, a0
                bra.s   lvl_player_animation_selected

            select_attack_2:
            btst    #player_attack_2, d6
            beq.s   select_attack_1
                lea     BaoLongTu_sprite_Attack20, a0
                bra.s   lvl_player_animation_selected

            select_attack_1:
            btst    #player_attack_1, d6
            beq.s   lvl_player_notattacking
                lea     BaoLongTu_sprite_Attack10, a0
                bra.s   lvl_player_animation_selected

        lvl_player_notattacking:
            btst    #sprite_jumping, d6
            beq.s   lvl_player_not_jumping
                lea     BaoLongTu_sprite_Jumping0, a0
                bra.s   lvl_player_animation_selected
            lvl_player_not_jumping:
            btst    #player_walking, d6
            beq.s   lvl_player_idle
                ; select walking frame - 2 frames for now
                move.w  (frame_counter), d5
                andi.w  #15, d5
                cmp.w   #8, d5
                bcs.s   player_walk_frame1          
                    lea     BaoLongTu_sprite_Walking0, a0
                    bra.s   lvl_player_animation_selected
                player_walk_frame1:
                    lea     BaoLongTu_sprite_Walking1, a0
                    bra.s   lvl_player_animation_selected
        lvl_player_idle:
            lea     BaoLongTu_sprite_Idle0, a0
    lvl_player_animation_selected:

    lea.l   MEM_player_previous_frame, a2
    move.l  a0, (a2)


    moveq   #0, d3              ; skip to sprite data
    move.w  (a0)+, d3
    add.w   d3, d3
    adda.l  d3, a0


    ******************************************************
    * START WORKING ON SPRITES
    * - populate buffer in RAM and then DMA
    ******************************************************
    moveq   #5, d4                                          ; d4 will keep track of *linking*

    ; obligatory "GTFO or die" flicker
    move.b  (MEM_player_vulnerability), d0
    btst    #player_dmg_invulnerable, d0
    beq.s   draw_player_sprite
        move.w  (MEM_player_inv_frames), d5
        beq.s   return_vulnerability
            subq    #1, d5
            move.w  d5, (MEM_player_inv_frames)
            move.w  (frame_counter), d5
            andi.w  #7, d5
            cmp.b   #4, d5
            bcs.s   draw_player_sprite
            bra.s   skip_player_sprite
        return_vulnerability:
            SetPlayerVulnerable
    draw_player_sprite:
        move.w  (MEM_player_sprite_index), d7
        bsr.w   DrawSpriteFrame
    skip_player_sprite:

    ***************************************************
    * ITEMS in level,  like enemies and collectibles
    ***************************************************
    moveq   #0, d5
    move.w  (MEM_LEVELITEM_COUNT), d5
    lea     MEM_LEVELITEMS, a4
    lea     lvl_item_update_done, a5            ; jmp back here after calling item subroutine

    lvl_pvitem_update:
        lea     Game_ItemTable, a3
        moveq   #0, d3
        move.b  (a4)+, d3           ; Pull out the type; a4 will have the STATE and POSITION in the callback
        add.w   d3, d3
        add.w   d3, d3

        movea.l	(a3,d3.w), a3        
        jmp     (a3)

        lvl_item_update_done:
        dbra    d5, lvl_pvitem_update

    ***************************************************
    * EFFECTS - blood, sparkles
    ***************************************************
    ; Assume effects are created by things happening on-screen and are always visible
    ; that is why we only allocate 16 of them.
    moveq   #0, d5
    move.w  (MEM_effects_count), d5
    beq.s   lvl_effects_done
        subq    #1, d5
        move.w  #0, (MEM_effects_count)         ; we will rebuild this later 

        lea     MEM_effects, a4
        movea.l a4, a2                      ; save a reference going backwards so we can rebuild with survivors

        lea     lvl_effect_update_done, a5

        lvl_effects_update:
            move.l  a4, -(SP)                  ; save a reference to the start of this object in case we're keeping it

            lea     Game_EffectTable, a3
            moveq   #0, d3
            move.b  (a4)+, d3
            add.w   d3, d3
            add.w   d3, d3

            movea.l	(a3,d3.w), a3        
            jmp     (a3)

            lvl_effect_update_done:

            ; d6 will hold the state of the effect. If it is 0, it is time to remove
            move.l  (SP)+, a0
            tst.b   d6
            beq.s   lvl_fx_skip
                move.w  (a0)+, (a2)+
                move.l  (a0)+, (a2)+
                addi.w  #1, (MEM_effects_count)
            lvl_fx_skip:

            dbra    d5, lvl_effects_update

    lvl_effects_done:

    bsr.w   CapSpriteBuffer

    EndLoop