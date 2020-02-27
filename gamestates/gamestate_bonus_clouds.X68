BONUS_CLOUD_TILES_COUNT         EQU     640
BONUS_CLOUD_TILES_BYTE_SIZE     EQU     BONUS_CLOUD_TILES_COUNT<<5

BONUS_PLAYER_VRAM_ADDR          EQU     (BONUS_CLOUD_TILES_COUNT+1)<<5

BONUS_PLAYER_SPEED              EQU     3
BONUS_PLAYER_WIDTH              EQU     29

BONUS_ROUND_TIME                EQU     30
BONUS_START_COUNTING_TIME       EQU     60

BONUS_END_TRANSITION_TIME       EQU     300

CB_ITEMS_HORIZON                EQU     sprite_view_vmin+70
CB_ITEMS_VANISH                 EQU     sprite_view_vmin+vdp_screen_height
CB_ITEMS_SHADOWHEIGHT           EQU     CB_ITEMS_HORIZON+40
CB_ITEM_SHADOWCLIP              EQU     312

CB_PLAYER_COLLISION_Y           EQU     292
CB_PLAYER_COLLISION_HEIGHT      EQU     32
CB_GEM_POINTS                   EQU     5

CB_EFFECT_EXPLOSION             EQU     0
CB_EFFECT_EXPLOSION_DURATION    EQU     32
CB_EFFECT_EXPLOSION_STARTVALUE  EQU     (CB_EFFECT_EXPLOSION<<8)|CB_EFFECT_EXPLOSION_DURATION
CB_EFFECT_EXPLOSION_FRAMES      EQU     4

CB_EFFECT_SPARKLE               EQU     1
CB_EFFECT_SPARKLE_DURATION      EQU     32
CB_EFFECT_SPARKLE_STARTVALUE    EQU     (CB_EFFECT_SPARKLE<<8)|CB_EFFECT_SPARKLE_DURATION

; Wobble macro for card and level
BonusPlayerWobble       macro
    swap    d1
    move.w  frame_counter, d3
    move.w  d3, d5
    andi.w  #3, d3
    bne.s   wobbled\@
        andi.w  #63, d5
        cmp.w   #32, d5
        blt.s   wobbledown\@
            subq    #1, d1
            bra.s   wobbled\@
wobbledown\@
        addq    #1, d1
wobbled\@
    move.w  d1, MEM_player_pos_y
    swap    d1
    endm

**************************************************************
* The "card" that comes just before the bonus stage
**************************************************************
Init_BonusCloudsCard:
    move.w	#interrupts_disable, sr
    jsr     ResetState
    ;bsr.w   UploadGameplaySFXProgram
    lea     BonusThemeBegin, a0
    move.l  #BonusThemeEnd-1, d0
    bsr.w   UploadBGM

    lea     Palette_BonusClouds, a0
    moveq   #4, d0
    bsr.w   LoadPalettes

    DMA68KtoVRAM    2880, Tiles_FontA, $20
    DMA68KtoVRAM    384, BonusCloudsTiles+11840, 11872

    lea     BonusCloudsCaption, a0
    move.w  #cram_palette_3_bits, d6
    move.l  #vdp_write_plane_a|$040E0000, d7
    bsr.w   PrintStringNoDMA
    
    move.l  #BaoLongTu_sprite_Walking0, MEM_player_previous_frame
    move.w  #2912, MEM_player_tiles_start

    move.l  #$00700092, MEM_player_pos
    
    ; copy sprites and player sprite
    move.b  #7, MEM_vblank_mode

    lea.l   vdp_data, a1

    move.w	#interrupts_enable, sr
    rts

MainLoop_BonusCloudsCard:
    cmp.w   #140, frame_counter
    bne.s   bcc_continue
        bsr.w   Init_BonusClouds
        lea     MainLoop_BonusClouds, a6
        move.b  #gamestate_bonus_clouds, MEM_gamestate
        EndLoop
    bcc_continue:

    move.l  MEM_player_pos, d1
    BonusPlayerWobble

    moveq   #1, d4

    lea.l   MEM_player_previous_frame, a2
    movea.l (a2), a0
    moveq   #0, d3              ; skip to sprite data
    move.w  (a0)+, d3
    add.w   d3, d3
    adda.l  d3, a0

    moveq   #0, d2
    move.w  #91|cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   DrawSpriteFrame

    ; draw 2 clouds since the player has a wide stance...
    lea     BonusNimbus, a0
    move.l  MEM_player_pos, d1
    addi.l  #((54<<16)|$FFED), d1
    moveq   #1, d7
    ori.w   #cram_palette_3_bits, d7
    bsr.w   DrawSprite

    lea     BonusNimbus, a0
    move.l  MEM_player_pos, d1
    addi.l  #((54<<16)|$0002), d1
    moveq   #1, d7
    ori.w   #cram_palette_3_bits, d7
    bsr.w   DrawSprite

    bsr.w   CapSpriteBuffer
    EndLoop

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
    addi.w  #score_vram_tile_offset, d1
    move.w  d1, (MEM_score_digits_id)
    lsl.w   #5, d1
    move.w  d1, (MEM_score_vram_address)
    
    bsr.w   LoadCoreGfx
    move.w  #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   CacheScoreSprites
    move.w  #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   CacheHealthSprite

    moveq   #5, d4          ; advance d4 so sprite buffer is capped correctly
    lea.l   vdp_data, a1    ; a1 permanently points to data port for this state

    lea.l   MEM_LEVELITEMS, a3  ; a3 will point to the items list from the previous frame

    ; set initial player graphics and position
    move.l  #BaoLongTu_sprite_FlyingRear0, (MEM_player_previous_frame)
    move.l  #$00900092, (MEM_player_pos)
    bset    #score_changed, frame_state

    SetPlayerVulnerable
    move.b  #player_max_hp, MEM_player_hp

    ;Set us up some bombs
    move.l  MEM_next_bonus_stage, d0
    move.l  d0, mem_events_ptr
    move.b  #BONUS_ROUND_TIME, mem_bonus_time

    ; DMA - Sprite buffer, player tiles, and score
    move.b  #7, MEM_vblank_mode
    EnableHBlank    #HBlank_BonusCloudsScroll, 1

    ; start the music!
    move.w  #sfx_spawn, d0
    bsr.w   SetSFX

    move.w	#interrupts_enable, sr
    rts

PlayerWon_BonusClouds:
    move.w  frame_counter, d6
    cmp.w   #BONUS_END_TRANSITION_TIME, d6
    beq.w   BC_TransitionNext

    move.b  mem_sprite_link, d4
    PointToNextSprite   d4, d3, a2

    lea     BonusClouds_Success1, a0
    move.l  #$00A80000|sprite_view_hmin+114, d1
    move.l  #$FFFB000A, d2
    move.w  #379|cram_palette_3_bits|vram_priority_bit, d5
    bsr.w   PrintFallingTextAsSprites

    move.w  frame_counter, d6
    sub.w   #$005A, d6
    bcs.s   bc_playerwon_skip_2
        lea     BonusClouds_Success2, a0
        move.l  #$00B20000|sprite_view_hmin+100, d1
        move.l  #$FFFB000A, d2
        move.w  #379|cram_palette_3_bits|vram_priority_bit, d5
        bsr.w   PrintFallingTextAsSprites
    bc_playerwon_skip_2:

    bsr.w   CapSpriteBuffer
    EndLoop

PlayerLostShame_BonusClouds:
    ;Shame on you!
    move.w  frame_counter, d6
    cmp.w   #BONUS_END_TRANSITION_TIME, d6
    beq.w   BC_TransitionNext

    move.b  mem_sprite_link, d4
    PointToNextSprite   d4, d3, a2

    lea     BonusClouds_Fail, a0
    move.l  #$00A80000|sprite_view_hmin+120, d1
    move.l  #$FFFB0008, d2
    move.w  #(BONUS_CLOUD_TILES_COUNT)|cram_palette_3_bits|vram_priority_bit, d5
    bsr.w   PrintFallingTextAsSprites

    move.w  frame_counter, d6
    cmp.w   #90, d6
    blt.s   skip_shame
        lea     BonusClouds_Fail2, a0
        move.l  #$00B80000|sprite_view_hmin+124, d1
        bsr.w   PrintTextAsSprites
    skip_shame:

    bsr.w   CapSpriteBuffer
    EndLoop
PlayerDead_BonusClouds:
    ; It's a long way down, homie
    move.w  MEM_player_pos_y, d1
    move.w  MEM_player_velocity_y, d0
    addi.w  #world_gravity, d0
    move.w  d0, MEM_player_velocity_y
    asr.w   #3, d0
    add.w   d0, d1
    move.w  d1, MEM_player_pos_y

    cmp.w   #vdp_screen_height, d1
    blt.s   bc_continue_playerdead
        jsr     PlayerDeathJingle
        lea     PlayerLostShame_BonusClouds, a6
        move.l  #HBlank_BonusCloudsNoScroll, MEM_hblank_handler

        ; Player is gone, DMA font in his place!
        bsr.w   BC_ReplacePlayerWithFont
        move.w  #0, frame_counter       ; reset frame counter\
        EndLoop
    bc_continue_playerdead:

MainLoop_BonusClouds:
    bsr.w   PauseGame

    moveq   #0, d0
    moveq   #0, d1
    move.w  frame_counter, d5
    btst    #player_dead, MEM_player_vulnerability
    bne.s   bc_skip_time_decrement
    cmp.w   #BONUS_START_COUNTING_TIME, d5
    bcs.s   bc_skip_time_decrement
        move.w  d5, d1
        ; 64 frames is about a second
        andi.w  #63, d1
        bne.s   bc_skip_time_decrement
            move.b  mem_bonus_time, d0
            subq    #1, d0
            bpl.s   bc_time_remaining
                move.w  #0, frame_counter
                lea     PlayerWon_BonusClouds, a6
                jsr     FanfareSFX
                move.l  #HBlank_BonusCloudsNoScroll, MEM_hblank_handler
                bsr.w   BC_ReplaceItemsWithFont
                move.b  #13, mem_sprite_link
                EndLoop
            bc_time_remaining:
            move.b  d0, mem_bonus_time
            bc_time_adjusted:
    bc_skip_time_decrement:

    ; Cycle palette to make the clouds go whoooshhh
    moveq   #0, d0
    move.b  #15, d0
    move.l  #(vdp_cram_write+$00200000), vdp_control
    lsr.w   #3, d5
    neg.w   d5
    wispy_cycle:
        lea     BCP_Wispy_Start, a0
        addq    #1, d5
        move.w  d5, d3
        andi.w  #15, d3
        add.b   d3, d3
        adda.l  d3, a0
        move.w  (a0), (a1)
        dbra    d0, wispy_cycle

    ; Not sure if scrolling helps or hinders the magic
    * move.w  d1, d3
    * add.w   d3, d3
    * move.l  #vdp_vram_vscroll, vdp_control
    * move.w  #0, (a1)
    * move.w  d3, (a1)


    

    *****************************************************************
    * PLAYER CONTROLS 
    *****************************************************************
    move.l  MEM_player_pos, d1
    btst    #player_dead, MEM_player_vulnerability
    bne.s   bc_player_dead0
        move.b	MEM_buttons_held, d0
        btst    #joypad_right, d0
        beq.s   bc_check_left              ; Not pressing right; see if pressing left
            ; Moving RIGHT
            addi.w  #BONUS_PLAYER_SPEED, d1
            bra.s   bc_lr_checked
        bc_check_left:
            btst    #joypad_left, d0
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
        BonusPlayerWobble
    bc_player_dead0:
    


    ********************************************************************
    * SPRITE DUMP
    ********************************************************************
    move.b  #5, d4          ; offset from cached GUI sprites

    moveq   #0, d2          ; static camera for subroutines that need it
    moveq   #0, d6

    *************************
    * EFFECTS like boom booms
    *************************
    moveq   #0, d0
    moveq   #0, d5
    move.w  MEM_effects_count, d5
    beq.s   bc_effects_skip
        subq    #1, d5
        move.w  #0, MEM_effects_count
        lea     MEM_effects, a2
        movea.l a2, a3
        bc_effects_loop:
            movea.l a2, a4
            move.b  (a2)+, d3
            bne.s   bc_choose_sparkle
                bsr.w   BC_DrawExplosion
                bra.s   bc_effect_chosen
            bc_choose_sparkle:
                bsr.w   BC_DrawSparkle
            bc_effect_chosen:
            
            beq.s   bc_effects_continue
                ; retain for next frame
                move.w  (a4)+, (a3)+
                move.l  (a4)+, (a3)+
                addi.w  #1, MEM_effects_count
            bc_effects_continue:
            dbra    d5, bc_effects_loop
    bc_effects_skip:

    ; see if the player sprite is flickering out
    btst    #player_dmg_invulnerable, MEM_player_vulnerability
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

        move.l  MEM_player_pos, d1
    move.w  (MEM_player_sprite_index), d7
    ori.w   #cram_palette_2_bits|vram_priority_bit, d7
    bsr.w   DrawSpriteFrame
    bc_player_skipped:


    ; draw the cloud and shadow below the player
    lea     BonusNimbus, a0
    btst    #player_dead, MEM_player_vulnerability
    beq.s   bc_cloud_follow_player
        move.w  #190, d1
        swap    d1
        move.w  MEM_player_pos_x, d1
        subq    #5, d1
        bra.s   bc_cloud_height_adjusted
    bc_cloud_follow_player:
        move.l  MEM_player_pos, d1
        addi.l  #((44<<16)|$FFFB), d1
    bc_cloud_height_adjusted:
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

    ***************************************************************
    * TIME REMAINING
    ***************************************************************
    lea     bc_time_label, a0
    move.l  #$0084010F, d1                                   ; "Time" label is centered and level with score/health
    move.w  #cram_palette_3_bits|vram_priority_bit, d7
    bsr.w   DrawSprite_Untransformed

    moveq   #0, d0
    move.b  mem_bonus_time, d0
    add.b   d0, d0
    lea     BC_TimeDigitTable, a2
    adda.l  d0, a2

    lea     bc_time_digits, a0
    move.b  (a2)+, d0
    adda.l  d0, a0
    move.l  #$00900114, d1
    bsr.w   DrawSprite_Untransformed

    lea     bc_time_digits, a0
    move.b  (a2), d0
    adda.l  d0, a0
    move.l  #$00900120, d1
    bsr.w   DrawSprite_Untransformed

    ****************************************************************
    * EVENTS - Spawn / Despawn items
    ****************************************************************
    ; EVENTS are stored in the LEVEL ITEMS buffer as flllows:
    ; YYYYXXXX.l - Y/X position
    ; 00TT.w - PADDING / TYPE 

    lea     MEM_LEVELITEMS, a3
    moveq   #0, d6

    move.w  MEM_LEVELITEM_COUNT, d0
    beq.w   bc_active_items_skip
        PointToNextSprite   d4, d3, a5
        subq    #1, d0
        moveq   #0, d5
        movea.l a3, a2
        bc_active_items_loop:
            move.l  (a2)+, d1
            move.l  d1, d2                      ; hold onto the original height for the drop shadow
            move.w  (a2)+, d3

            swap    d1
            cmp.w   #CB_ITEMS_VANISH, d1        ; skip when beyond the screen
            bcc.w   bc_active_item_skip

            cmp.w   #CB_PLAYER_COLLISION_Y, d1
            bcs.s   bc_active_item_no_collision

            cmp.w   #CB_PLAYER_COLLISION_Y+CB_PLAYER_COLLISION_HEIGHT, d1
            bhi.s   bc_active_item_no_collision
                swap    d1
                move.w  MEM_player_pos_x, d5
                add.w   #sprite_view_hmin, d5
                sub.w   d1, d5
                AbsWord d5
                swap    d1
                cmp.w   #BONUS_PLAYER_WIDTH, d5
                bhi.s   bc_active_item_no_collision
                    ; COLLISION!!!!
                    swap    d1
                    tst.b   d3
                    beq.w   BC_BombHitPlayer
                    bra.w   BC_PlayerGotGem
            bc_active_item_no_collision:

            ; Item is still good, retain the 6 bytes while drawing the sprite
            ; do the sprites in-line
            addq    #1, d1
            swap    d1
            move.l  d1, (a3)+           ; update actual position for item entry
            move.w  d3, (a3)+        ; retain type
            swap    d1

            ; determine the offset and image to use
            move.w  d1, d5
            sub.w   #CB_ITEMS_HORIZON, d5
            lsr.w   #3, d5
            add.w   d5, d5
            add.w   d5, d5              ; have to quadruple after the fact for clamping effect
            ClampToByte     d5, #24

            lea     BonusBombOffsets, a0
            adda.l  d5, a0
            add.l   (a0)+, d1
            
            tst.b   d3                          ; Only two "items" can spawn
            beq.s   bc_active_item_bomb
            bc_active_item_gem:
                lea     BonusGemScaling, a0
                bra.s   bc_active_item_set
            bc_active_item_bomb:
                lea     BonusBombScaling, a0
            bc_active_item_set:
            
            adda.l  d5, a0

            move.w  d1, (a5)+           ; y offset

            move.w  (a0)+, d5
            add.w   d4, d5
            addq    #1, d4
            move.w  d5, (a5)+           ; size and link

            move.w  (a0)+, d5
            ori.w   #cram_palette_2_bits|vram_priority_bit, d5
            move.w  d5, (a5)+           ; Tile ID / flags

            swap    d1
            move.w  d1, (a5)+        ; x offset


            ; Draw a drop shadow - this pushes us close to the raster limits so only draw within a certain range
            swap    d2
            cmp.w   #CB_ITEMS_SHADOWHEIGHT, d2
            bcs.s   bc_item_skip_shadow
            cmp.w   #CB_ITEM_SHADOWCLIP, d2
            bhi.s   bc_item_skip_shadow
                lea     BCDropShadow, a0
                addi.l  #$000A0024, d2
                move.w  d2, (a5)+                        ; first is y offset

                move.w  (a0)+, d3
                add.w   d4, d3
                addq    #1, d4
                move.w  d3, (a5)+                        ; second is size and link

                move.w  (a0)+, d5
                ori.w   #cram_palette_3_bits|vram_priority_bit, d5
                move.w  d5, (a5)+           ; Tile ID / flags

                swap    d2
                move.w  d2, (a5)+                        ; last is x offset
            bc_item_skip_shadow:

            
            addq    #1, d6
            bc_active_item_skip:

            dbra    d0, bc_active_items_loop     
    bc_active_items_skip:
    
    ; Clip off the sprite buffer - no new sprites from here
    move.b  d4, mem_sprite_link
    bsr.w   CapSpriteBuffer
    ***********************************************
    * Parse any incoming events that need to spawn
    ***********************************************
    move.w  frame_counter, d1
    movea.l mem_events_ptr, a0
    move.w  (a0)+, d0

    cmp.w   #$FFFF, d0
    beq.s   BC_NewEventsSkip

    cmp.w   d1, d0
    bne.s   BC_NewEventsSkip

    moveq   #0, d0
    move.w  (a0)+, d0
    BC_NewEventLoop:
        addq    #1, d6                      ; Add one to the level item count
        move.w  #CB_ITEMS_HORIZON, (a3)+    ; Y Position for item
        move.b  (a0)+, d1
        moveq   #0, d3
        move.b  (a0)+, d3
        add.w   d3, d3
        move.w  d3, (a3)+                   ; X position for item
        move.b  #0, (a3)+                   ; padding
        move.b  d1, (a3)+                   ; Type for item
        dbra    d0, BC_NewEventLoop
        move.l  a0, mem_events_ptr
    BC_NewEventsSkip:
    
    move.w  d6, MEM_LEVELITEM_COUNT
    EndLoop


HBlank_BonusCloudsNoScroll
    move.w	#interrupts_disable, sr
    movem.l d0/a0, -(SP)
    moveq   #0, d0
    move.b  mem_hblank_counter, d0
    addq    #1, d0
    move.b  d0, mem_hblank_counter
    bra.s   HBlank_BonusCloudsTexture
HBlank_BonusCloudsScroll:
    move.w	#interrupts_disable, sr
    movem.l d0/a0, -(SP)
    moveq   #0, d0
    move.w  frame_counter, d0
    neg     d0
    lsr.b   #1, d0
    add.b  mem_hblank_counter, d0
    addi.b  #1, mem_hblank_counter
HBlank_BonusCloudsTexture:
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

    movem.l (SP)+, d0/a0
    rte

; Item update Subroutines - keep these close
BC_BombHitPlayer:
    bsr.s   BC_HurtPlayer
    ; d1 should still have the actual position of this object
    subi.l  #sprite_viewport_offset, d1
    moveq   #CB_EFFECT_EXPLOSION_STARTVALUE, d7
    bsr.w   AddEffect
    jsr     PlayerHurtJingle
    bra.w   bc_active_item_skip

BC_PlayerGotGem:
    subi.l  #sprite_viewport_offset, d1
    move.w  #CB_EFFECT_SPARKLE_STARTVALUE, d7
    bsr.w   AddEffect
    AddPoints   #CB_GEM_POINTS
    move.w  d0, -(SP)
    move.w  #sfx_collect, d0
    jsr     SetSFX
    move.w  (SP)+, d0
    bra.w   bc_active_item_skip

BC_HurtPlayer:
    btst    #player_vulnerable, MEM_player_vulnerability
    beq.s   bc_skiphurtplayer

    move.b  MEM_player_hp, d3
    subq    #1, d3
    move.b  d3, MEM_player_hp
    bne.s   bc_player_alive
        move.b  #$10, MEM_player_vulnerability           ; dead as a doorknob
        move.l  #BaoLongTu_sprite_Dead0, MEM_player_previous_frame
        lea     PlayerDead_BonusClouds, a6
        move.w  #player_death_velocity, MEM_player_velocity_y        
        bra.s   bc_hurtplayer_end
    bc_player_alive:
        move.b  #4, MEM_player_vulnerability
        move.w  #player_hurt_duration<<1, MEM_player_inv_frames         ; double the invincibility time in the bonus stage
    bc_hurtplayer_end:
        jsr UpdateHealthGfx 
    bc_skiphurtplayer:
    rts

BC_DrawExplosion:
    move.b  (a2), d3
    subq    #1, d3
    move.b  d3, (a2)+
    move.l  (a2)+, d1
    tst.b   d3
    beq.s   bc_explosion_end
        move.w  #vram_priority_bit|cram_palette_3_bits, d7
        ; pick frame based on where we are in the animation
        lea     Explosion_Explode+2, a0
        lsr.w   #3, d3
        add.w   d3, d3
        add.w   d3, d3
        movea.l	(a0,d3.w), a0 

        bsr.w   DrawSpriteFrame
        moveq   #1, d3
    bc_explosion_end:
    rts

BC_DrawSparkle:
    move.b  (a2), d3
    subq    #1, d3
    move.b  d3, (a2)+
    move.l  (a2)+, d1
    tst.b   d3
    beq.s   bc_sparkle_end
        lea     BC_GemSparkle, a0
        move.w  #cram_palette_2_bits|vram_priority_bit, d7
        andi.b  #7, d3
        cmp.b   #4, d3
        blt.s   bc_sparkle_noflip
            ori.w   #vram_hflip_bit, d7
        bc_sparkle_noflip:
        bsr.w   DrawSprite  
        moveq   #1, d3
    bc_sparkle_end:
    rts

BC_ReplacePlayerWithFont:
    DMA68KtoVRAM    2048, Tiles_FontA, BONUS_PLAYER_VRAM_ADDR
    rts

BC_ReplaceItemsWithFont:
    DMA68KtoVRAM    2880, Tiles_FontA, 12160
    rts

BC_TransitionNext:
    jsr     Goto_NextLevel
    EndLoop