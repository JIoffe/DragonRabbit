BONUS_CLOUD_TILES_COUNT         EQU     499
BONUS_CLOUD_TILES_BYTE_SIZE     EQU     BONUS_CLOUD_TILES_COUNT<<5

BONUS_PLAYER_SPEED              EQU     3
BONUS_PLAYER_WIDTH              EQU     29

CB_ITEMS_HORIZON                EQU     sprite_view_vmin+80
CB_ITEMS_VANISH                 EQU     vdp_screen_height-80
CB_PLAYER_COLLISION_HEIGHT      EQU     90                      ; offset from horizon

CB_GEM_POINTS                   EQU     25


***************************************************************
* Bonus Level Prototype
* -------------------------------------------------------------
* Player can move left and right while flying through the clouds
* and avoiding bombs until time runs out or the player dies.
* The player can gather green orb things for points
*
* The MEM_LEVELITEMS buffer will be populated with bombs or point balls
* via a timeline-based list. 
* 1st Byte - Type: 0=Bomb, 1=Orb
* 2nd Byte - 0xYX Velocity per update (updated every 2nd frame)
* Last 4 bytes - 0xYYYYXXXX position onscreen

Init_BonusClouds:
    move.w	#interrupts_disable, sr
    lea.l   vdp_data, a1    ; a1 permanently points to data port for this state

    EnableHBlank    #HBlank_BonusClouds, 1
    jsr     ResetState
    bsr.w   ClearLevelVars

    lea     Palette_BonusClouds, a0
    moveq   #4, d0
    bsr.w   LoadPalettes

    DMA68KtoVRAM    BONUS_CLOUD_TILES_BYTE_SIZE, BonusCloudsTiles, $20

    ; Draw the distorted cloud base texture
    move.l  #vdp_write_plane_a, a5
    move.l  #$0F140000, d5
    lea     BonusCloudPlane, a0
    bsr.w   Plane_DrawPattern

    move.l  #$0F000000, d5
    lea     BonusCloudPlane, a0
    bsr.w   Plane_DrawPatternFlipH

    ; Draw the little horizon line
    move.l  #vdp_write_plane_a+$07000000, vdp_control
    move.w  #371|cram_palette_3_bits|vram_priority_bit, d1
    moveq   #0, d0
    move.w  #39, d0
    bclouds_horizon:
        move.w  d1, (a1)
        dbra    d0, bclouds_horizon

    ; fill blue sky in plane A
    move.l  #vdp_write_plane_a, vdp_control
    moveq   #0, d0
    move.w  #895, d0
    move.w  #356|cram_palette_3_bits, d1
    bonusclouds_blue_fill:
        move.w  d1, (a1)
        dbra    d0, bonusclouds_blue_fill

    ; add some bitchin' clouds.
    move.l  #vdp_write_plane_b, a5
    move.l  #$00140000, d5
    lea     BonusWispyClouds, a0
    bsr.w   Plane_DrawPattern

    move.l  #$00000000, d5
    lea     BonusWispyClouds, a0
    bsr.w   Plane_DrawPatternFlipH

    ; Load in Core Sprites to display things like the score and setup the player buffer
    move.w  #BONUS_CLOUD_TILES_COUNT+1, d1
    move.w  d1, (MEM_player_sprite_index)
    move.w  d1, d5
    lsl.w   #5, d5
    move.w  d5,  (MEM_player_tiles_start)

    add.w   #player_tile_allocation, d1
    move.w  d1, (MEM_UI_sprite_start)
    addi.w  #85, d1
    move.w  d1, (MEM_score_digits_id)
    lsl.w   #5, d1
    move.w  d1, (MEM_score_vram_address)
    
    bsr.w   LoadCoreGfx
    move.w  #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   CacheScoreSprites
    bsr.w   UpdateScoreGfx
    move.w  #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   CacheHealthSprite

    moveq   #5, d4          ; advance d4 so sprite buffer is capped correctly

    moveq   #0, d7          ; d7 will be the line counter
    lea.l   vdp_data, a1    ; a1 permanently points to data port for this state


    ; set initial player graphics and position
    move.l  #BaoLongTu_sprite_FlyingRear0, (MEM_player_previous_frame)
    move.l  #$00900040, (MEM_player_pos)

    SetPlayerVulnerable
    move.b  #player_max_hp, MEM_player_hp

    ; Addddd a bomb!!!
    move.w  #1, MEM_LEVELITEM_COUNT
    lea     MEM_LEVELITEMS, a0
    move.w  #$0110, (a0)+
    move.l  #$00900090, (a0)+



    ; DMA - Sprite buffer and player tiles on each frame
    move.b  #3, MEM_vblank_mode
    move.w	#interrupts_enable, sr
    rts

MainLoop_BonusClouds:
    bsr.w   UpdateScoreGfxIfDirty

    moveq   #0, d1
    move.w  frame_counter, d1

    ; Not sure if scrolling helps or hinders the magic
    * move.w  d1, d3
    * add.w   d3, d3
    * move.l  #vdp_vram_vscroll, vdp_control
    * move.w  #0, (a1)
    * move.w  d3, (a1)

    ; Cycle palette to make the clouds go whoooshhh
    moveq   #0, d0
    move.b  #15, d0
    move.l  #(vdp_cram_write+$00200000), vdp_control
    lsr.w   #3, d1
    neg.w   d1
    wispy_cycle:
        lea     BCP_Wispy_Start, a0
        addq    #1, d1
        move.w  d1, d3
        andi.w  #15, d3
        add.b   d3, d3
        adda.l  d3, a0
        move.w  (a0), (a1)
        dbra    d0, wispy_cycle


    

    *****************************************************************
    * PLAYER CONTROLS 
    *****************************************************************
    move.l  MEM_player_pos, d1
    move.b	(MEM_buttons_held), d0

    move.b  d0, d3
    andi.b  #joypad_right, d3
    beq.s   bc_check_left              ; Not pressing right; see if pressing left
        ; Moving RIGHT
        addi.w  #BONUS_PLAYER_SPEED, d1
        bra.s   bc_lr_checked
    bc_check_left:
        move.b	d0, d3
        andi.b  #joypad_left, d3
        beq.s   bc_lr_checked
            ; Moving LEFT
            subi.w  #BONUS_PLAYER_SPEED, d1
    bc_lr_checked:

    tst.w   d1
    bpl.s   bc_clip_left
        move.w  #0, d1
        bra.s   bc_clipped
    bc_clip_left:
    cmp.w   #vdp_screen_width-BONUS_PLAYER_WIDTH, d1
    ble.s   bc_clipped
        move.w   #vdp_screen_width-BONUS_PLAYER_WIDTH, d1
    bc_clipped:

    move.w  d1, MEM_player_pos_x

    ; wobble a bit in the air to look like we're floating...
    swap    d1
    move.w  frame_counter, d3
    move.w  d3, d5
    andi.w  #3, d3
    bne.s   bc_wobbled
        andi.w  #63, d5
        cmp.w   #32, d5
        blt.s   bc_wobbledown
            subq    #1, d1
            bra.s   bc_wobbled
        bc_wobbledown:
        addq    #1, d1
    bc_wobbled:
    move.w  d1, MEM_player_pos_y
    swap    d1
    


    ********************************************************************
    * SPRITE DUMP
    ********************************************************************
    moveq   #5, d4

    move.b  d7, -(SP)

    moveq   #0, d2          ; static camera for subroutines that need it
    moveq   #0, d6
    moveq   #0, d0

    ; see if the player sprite is flickering out
    move.b  (MEM_player_vulnerability), d0
    btst    #player_hurt_recoil, d0
    beq.s   bc_draw_player_sprite
    move.w  (MEM_player_inv_frames), d5
    beq.s   bc_return_vulnerability
        subq    #1, d5
        move.w  d5, (MEM_player_inv_frames)
        move.w  (frame_counter), d5
        andi.w  #7, d5
        cmp.b   #4, d5
        blt.s   bc_draw_player_sprite
        bra.s   bc_player_skipped
    bc_return_vulnerability:
        SetPlayerVulnerable

    bc_draw_player_sprite:
    lea.l   MEM_player_previous_frame, a2
    move.l  (a2), a0
    moveq   #0, d3              ; skip to sprite data
    move.w  (a0)+, d3
    add.w   d3, d3
    adda.l  d3, a0

    move.w  (MEM_player_sprite_index), d7
    ori.w   #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   DrawSpriteFrame
    bc_player_skipped:

    ; draw the cloud and shadow below the player
    move.w  frame_counter, d6
    andi.w  #1, d6

    lea     BonusNimbus, a0
    move.l  MEM_player_pos, d1
    addi.l  #((44<<16)|$FFFB), d1
    moveq   #1, d7
    ori.w   #cram_palette_3_bits|vram_priority_bit, d7
    bsr.w   DrawSprite

    lea     BCDropShadow, a0
    move.w  #cram_palette_3_bits|vram_priority_bit, d7
    move.w  #210, d1
    swap    d1
    move.w  MEM_player_pos_x, d1
    addq    #6, d1
    bsr.w   DrawSprite

    ; Incoming items! They set us up the bomb
    ; Only advance bombs every other frame
    moveq   #0, d6
    move.w  frame_counter, d6
    andi.w  #1, d6

    moveq   #0, d0
    move.w  MEM_LEVELITEM_COUNT, d0
    beq.s   bc_items_skipped
    subq    #1, d0
    lea     MEM_LEVELITEMS, a2
    movea.l a2, a3                          ; Rebuild list with surviving bombs
    moveq   #0, d6                          ; d6 will hold new count
    bc_items_loop:
        lea     BonusBombOffsets, a5
        move.b  (a2)+, d3
        bne.s   bc_item_pointball
            lea     BonusBombScaling, a0
            lea     BC_BombHitPlayer, a4
            bra.s   bc_item_selected
        bc_item_pointball:
            lea     BonusGemScaling, a0
            lea     BC_PlayerGotGem, a4
        bc_item_selected:
        bsr.w   BC_ItemUpdate
        dbra    d0, bc_items_loop
    
    move.w  d6, MEM_LEVELITEM_COUNT
    bc_items_skipped:
    * move.l  #$00900090, d1
    * lea     BCBomb100, a0
    * move.w  #cram_palette_2_bits|vram_priority_bit, d7
    * bsr.w   DrawSprite_Untransformed
    * lea     gem, a0
    * moveq   #0, d7
    * move.w  (MEM_UI_sprite_start), d7
    * addq    #1, d7
    * move.l  MEM_player_pos, d1
    * subi.l  #$00200000, d1
    * ori.w   #cram_palette_2_bits|vram_priority_bit, d7
    * bsr.w   DrawSprite



    move.b  (SP)+, d7
    EndLoop


HBlank_BonusClouds:
    * move.w	#interrupts_disable, sr
    moveq   #0, d0
    move.b  d7, d0
    addi.b  #1, d7
    move.w  frame_counter, d1
    lsr.w   #1, d1
    sub.w   d1, d0

    andi.w  #15, d0
    asl.w   #5, d0

    ; Based on the scanline and frame #, move the appropriate texture line into CRAM
    lea     BonusCloudTexture, a0 
    adda.l  d0, a0

    move.l  #vdp_cram_write, vdp_control
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0)+, (a1)
    move.w  (a0), (a1)
    rte

; Item update Subroutines - keep these close
BC_ItemUpdate:
    move.b  (a2)+, d1           ; right now the velocity is a "no-op" - testing with everything going straight down
    move.l  (a2), d1

    ; pick the right bomb for the job!
    move.l  d1, d2 
    swap    d1
    moveq   #0, d3
    move.w  d1, d3
    swap    d1
    sub.w   #CB_ITEMS_HORIZON, d3
    bmi.w   bc_item_skipped
    cmp.w   #CB_ITEMS_VANISH, d3
    blt.s   bc_item_draw
        ; bombs away!
        bra.w   bc_item_end
    bc_item_draw:
        ; see if bomb is hitting player (an approximation)
        cmp.w   #CB_PLAYER_COLLISION_HEIGHT, d3
        blt.s   bc_item_alive
            move.w  d1, d7
            sub.w   #sprite_view_hmin, d7
            sub.w   MEM_player_pos_x, d7            ; absolute value - is distance less than player width?
            bpl.s   cb_collision_adjust
                neg d7
            cb_collision_adjust:
            cmp.w   #BONUS_PLAYER_WIDTH, d7
            bgt.s   bc_item_alive
                jmp (a4)
        bc_item_alive:
        lsr.w   #3, d3
        add.w   d3, d3
        add.w   d3, d3
        cmp.b   #24, d3
        blt.s   cb_item_frame_limited
            move.b  #24, d3
        cb_item_frame_limited:
        adda.l  d3, a0
        adda.l  d3, a5
        add.l   (a5), d1

    move.w  #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   DrawSprite_Untransformed

    lea     BCDropShadow, a0
    move.w  #cram_palette_3_bits|vram_priority_bit, d7
    move.l  d2, d1
    addi.l  #$0024000A, d1
    bsr.w   DrawSprite_Untransformed
    bc_item_skipped:

    tst.w   d6
    bne.s   bc_item_adjusted
        move.l  #$00010000, d5      ; testing without any perspective distortion for now
        add.l   d5, d2
        move.l  d2, (a2)
    bc_item_adjusted:
    addq    #1, d6                  ; retain for next frame
    subq    #2, a2
    move.w  (a2)+, (a3)+
    move.l  (a2)+, (a3)+
    bc_item_end:
    rts

BC_BombHitPlayer:
    DamagePlayer    d3
    bra.s   bc_item_end

BC_PlayerGotGem:
    AddPoints   #CB_GEM_POINTS
    bra.s   bc_item_end