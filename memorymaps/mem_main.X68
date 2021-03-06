* MEMORY USAGE: 2594 byte(s)
mem_start                       EQU $FFFF0000       ;(alias)
frame_state                     EQU $FFFF0000       ;WORD
frame_counter                   EQU $FFFF0002       ;WORD
MEM_buttons_held                EQU $FFFF0004       ;BYTE
MEM_buttons_pressed             EQU $FFFF0005       ;BYTE
MEM_gamestate                   EQU $FFFF0006       ;BYTE
MEM_player_state                EQU $FFFF0007       ;BYTE
MEM_player_pos                  EQU $FFFF0008       ;(alias)
MEM_player_pos_y                EQU $FFFF0008       ;WORD
MEM_player_pos_x                EQU $FFFF000A       ;WORD
MEM_camera_pos                  EQU $FFFF000C       ;(alias)
MEM_camera_pos_y                EQU $FFFF000C       ;WORD
MEM_camera_pos_x                EQU $FFFF000E       ;WORD
MEM_player_velocity             EQU $FFFF0010       ;(alias)
MEM_player_velocity_y           EQU $FFFF0010       ;WORD
MEM_player_velocity_x           EQU $FFFF0012       ;WORD
MEM_player_tiles_start          EQU $FFFF0014       ;WORD
MEM_player_sprite_index         EQU $FFFF0016       ;WORD
MEM_player_jump_frames          EQU $FFFF0018       ;BYTE
MEM_player_attack_frames        EQU $FFFF0019       ;BYTE
MEM_UI_sprite_start             EQU $FFFF001A       ;WORD
MEM_fade                        EQU $FFFF001C       ;BYTE
MEM_player_att_strength         EQU $FFFF001D       ;BYTE
MEM_LEVELITEM_COUNT             EQU $FFFF001E       ;WORD
MEM_LEVELITEMS                  EQU $FFFF0020       ; ARRAY: 256 x 6 Byte(s)
MEM_playerattack_min            EQU $FFFF0620       ;(alias)
MEM_playerattack_ymin           EQU $FFFF0620       ;WORD
MEM_playerattack_xmin           EQU $FFFF0622       ;WORD
MEM_playerattack_max            EQU $FFFF0624       ;(alias)
MEM_playerattack_ymax           EQU $FFFF0624       ;WORD
MEM_playerattack_xmax           EQU $FFFF0626       ;WORD
MEM_effects_count               EQU $FFFF0628       ;WORD
MEM_effects                     EQU $FFFF062A       ; ARRAY: 16 x 6 Byte(s)
MEM_score                       EQU $FFFF068A       ;LONG
MEM_score_vram_address          EQU $FFFF068E       ;WORD
MEM_score_digits_id             EQU $FFFF0690       ;WORD
MEM_score_vram_data             EQU $FFFF0692       ; ARRAY: 8 x 32 Byte(s)
MEM_sprite_buffer               EQU $FFFF0792       ; ARRAY: 80 x 8 Byte(s)
MEM_player_previous_frame       EQU $FFFF0A12       ;LONG
MEM_player_vulnerability        EQU $FFFF0A16       ;BYTE
MEM_player_hp                   EQU $FFFF0A17       ;BYTE
MEM_player_inv_frames           EQU $FFFF0A18       ;WORD
MEM_level_restart_address       EQU $FFFF0A1A       ;LONG
MEM_palette                     EQU $FFFF0A1E       ;LONG
MEM_plane_buffer                EQU $FFFF0A22       ; Array: 64 * 32 * 2 bytes
MEM_hblank_handler              EQU $FFFF1A22       ;long (address)
MEM_vblank_mode                 EQU $FFFF1A26       ;byte
mem_hblank_counter              EQU $FFFF1A27       ;byte   - reset every vblank
mem_events_ptr                  EQU $FFFF1A28       ;LONG
mem_sprite_link                 EQU $FFFF1A2C       ; BYTE
mem_sprite_cap                  EQU $FFFF1A2D       ; byte
mem_bonus_time                  EQU $FFFF1A2E       ; byte
mem_boss_state                  EQU $FFFF1A2F       ; byte
mem_level_playerscan_offset     EQU $FFFF1A30       ;word
mem_level_deathbound            EQU $FFFF1A32       ;word
mem_level_playerscanh_offset    EQU $FFFF1A34       ;word
MEM_end                         EQU $FFFF1A36       ; ("END" of variables to clear when restarting a level)

; References on where to go when a level is over
MEM_next_level                  EQU $FFFF1A36       ;LONG pointer to code that calls next level
MEM_next_bonus_stage            EQU $FFFF1A3A       ;LONG pointer to code that calls next bonus data
MEM_level_bgm_begin             EQU $FFFF1A3E       ;LONG pointer to BGM to use for next level
MEM_level_bgm_end               EQU $FFFF1A42       ;LONG pointer to BGM to use for next level

; In case any additional init has to happen for a level
MEM_level_post_init_handler     EQU $FFFF1A46       ;LONG
