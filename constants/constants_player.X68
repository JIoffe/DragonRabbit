player_tile_allocation          EQU $40

; Player combo moves
player_attack_1         EQU $03
player_attack_2         EQU $04
player_attack_3         EQU $05
player_attack_4         EQU $06

player_walking          EQU $07

player_attack_duration  EQU $08
player_combo_time       EQU $20

player_height           EQU $40
player_height_tiles     EQU (player_height>>3)
player_width            EQU $18
player_width_tiles      EQU (player_width>>3)
player_width_tbytes     EQU (player_width_tiles<<1)
player_side_scan_height EQU player_height_tiles-1             ; Give some wiggle room when scanning for side-to-side collisions
player_bb_offset        EQU (player_height<<16)|player_width

player_attack_width     EQU $26
player_attack_height    EQU player_height
player_attack_bboffset  EQU (player_height<<16)|player_attack_width

player_x_speed          EQU $02

player_jump_strength    EQU -$1A
player_death_velocity   EQU -$2D

player_jump_duration    EQU $18             ; number of frames the player can hold jump to jump higher

player_tile_allocation  EQU $40             ; keep 64 tiles free for the player animation at all times

player_hurt_duration    EQU $1C
player_dmg_inv_duration EQU $58             ; how long the player is invulnerable after being hit

; Player invulnerability states
player_vulnerable       EQU $0
player_hurt_recoil      EQU $1              ; recoiling from hit disables controls
player_dmg_invulnerable EQU $2
player_dead             EQU $4

player_max_hp           EQU $3