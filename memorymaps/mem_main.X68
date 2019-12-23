* MEMORY USAGE: 1939 byte(s)
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
MEM_palette                     EQU $FFFF0792       ;BYTE
