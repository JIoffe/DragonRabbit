*==============================================================
* Constants for Genesis
*==============================================================
ram_start               EQU $FF0000
ram_end                 EQU $FFFFFF

* Send interrupt enable/disable to sr
interrupts_enable       EQU $2000
interrupts_disable      EQU $2700

*-------------------------------
* Controls
*-------------------------------
joypad_1_data           EQU $00A10003
joypad_2_data           EQU $00A10005
joypad_x_data           EQU $00A10007
joypad_1_control        EQU $00A10009
joypad_2_control        EQU $00A1000B
joypad_x_control        EQU $00A1000D

* button bitflags
joypad_up               EQU $01
joypad_down             EQU $02
joypad_left             EQU $04
joypad_right            EQU $08
joypad_b                EQU $10
joypad_c                EQU $20
joypad_a                EQU $40
joypad_start            EQU $80

*=====================================
* VDP Constants
*=====================================
* Note on VDP: Color is X B G R
* VDP port addresses
vdp_hv_counter          EQU $00C00008
vdp_control             EQU $00C00004
vdp_data                EQU $00C00000
vdp_register_count      EQU $17

* VDP VRAM Locations - VRAM nametable locations have to match certain multiples
vdp_vram_plane_a_addr   EQU $C000
vdp_vram_plane_b_addr   EQU $E000
vdp_vram_window_addr    EQU $A000

*(ADDR)     (COMMAND) sent to control port ($c00004)
*$0000	=> $40000000
*$1000	=> $50000000
*$2000	=> $60000000
*$3000	=> $70000000
*$4000	=> $40000001
*$5000	=> $50000001
*$6000	=> $60000001
*$7000	=> $70000001
*$8000	=> $40000002
*$9000	=> $50000002
*$A000	=> $60000002
*$B000	=> $70000002
*$C000	=> $40000003
*$D000	=> $50000003
*$E000	=> $60000003
*$F000	=> $70000003
*$FFFF	=> $7FFF0003

* VDP Access Commands
vdp_cram_read           EQU $20000000
vdp_cram_write          EQU $C0000000
vdp_vram_read           EQU $00000000
vdp_vram_write          EQU $40000000

vdp_write_plane_a       EQU $40000003
vdp_vram_window         EQU $60000002
vdp_write_plane_b       EQU $60000003

vdp_vram_hscroll        EQU $7C000002
vdp_vram_vscroll        EQU $40000010

vdp_vram_tiles          EQU $40200000       ;This address is at the second tile, so the first tile is always blank
vdp_vram_sprite         EQU $78000002
vdp_vsram_read          EQU $10000000
vdp_vsram_write         EQU $14000000
    
* VDP Screen width and height (in pixels)
vdp_screen_width        EQU $0140
vdp_screen_height       EQU $00F0
vdp_screen_max          EQU (vdp_screen_height<<16)|vdp_screen_width

vdp_visible_tile_width  EQU $28             ; Depends on VDP Mode Register 4
vdp_plane_vis_byte_w    EQU vdp_visible_tile_width<<1
vdp_plane_vis_pixel_w   EQU vdp_visible_tile_width<<3

vdp_plane_tile_width    EQU $40             ; Depends on VDP Register 16
vdp_plane_byte_width    EQU $80
vdp_plane_pixel_width   EQU $0200
vdp_plane_pixel_height  EQU $0100

vdp_visible_tile_height EQU $1C
vdp_plane_tile_height   EQU $20

vdp_plane_n_tiles       EQU $0800

cram_palette_0_bits     EQU $0000
cram_palette_1_bits     EQU $2000
cram_palette_2_bits     EQU $4000
cram_palette_3_bits     EQU $6000

; For Sprites and individual tiles
vram_priority_bit       EQU $8000
vram_vflip_bit          EQU $1000
vram_hflip_bit          EQU $0800

; Sprite Viewport
sprite_view_hmin        EQU $0080
sprite_view_hmax        EQU $01BF

sprite_view_vmin        EQU $0080
sprite_view_vmax        EQU $015F

sprite_viewport_offset  EQU (sprite_view_vmin<<16)|sprite_view_hmin

vram_sprites_address    EQU $B800





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
