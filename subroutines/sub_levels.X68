*------------------------------
* Levels / Tile Plans
*------------------------------

**********************************************************
* Fills the frame with level tiles given a camera location
**********************************************************
; d2 - Level Height (in tiles)
; d3 - Level width (in tiles)
; d4 - Level rowskip (d3 * 2);
Level_FillFrame:
    move.l  #vdp_visible_tile_height-1, d1

    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2
    move.w  (a0)+, d3

    sub.w   #vdp_visible_tile_width,   d3                   ; difference between level width and plane width
    add.l   d3, d3                                          ; tiles * 2 byte offset to skip rows in the level data

    move.l  #vdp_write_plane_a, d7
    framefill_loop:
        move.l  d7, vdp_control
        move.l  #vdp_visible_tile_width-1, d0               ; plane width is 64 tiles
        lff_fill:
            move.w  (a0)+, vdp_data
            dbra    d0, lff_fill

        add.l   d3, a0                                      ; Advance level data pointer

        swap    d7
        addi.w  #vdp_plane_byte_width,  d7                  ; Advance vdp command pointer
        swap    d7

        dbra    d1, framefill_loop 
    rts