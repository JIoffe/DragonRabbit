vsync_dump_sprites    EQU   0
vsync_dump_player     EQU   1


score_label_position    EQU ((sprite_view_vmin+4)<<16)|(sprite_view_hmin+4)
score_pts_position_x    EQU sprite_view_hmin+4
score_pts_position_y    EQU sprite_view_vmin+12