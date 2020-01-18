vsync_dump_sprites    EQU   0
vsync_dump_player     EQU   1
vsync_dump_score      EQU   2

score_label_position    EQU ((sprite_view_vmin+4)<<16)|(sprite_view_hmin+4)
score_pts_position_x    EQU sprite_view_hmin+4
score_pts_position_y    EQU sprite_view_vmin+12

health_sprite_x         EQU (447-36)
health_sprite_y         EQU (sprite_view_vmin+4)

score_vram_tile_offset  EQU 85 ; Offset from core tile definitions to place rendered score