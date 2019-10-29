******************************************************
* Adds a compound/embedded sprite frame to the VDP.
* Assumes that sprite tile data is in-line
* USE:

* d5: Offset in bytes to write to tile vram
* a0: set to frame start
* 
PushEmbeddedSpriteFrame:
    moveq   #0, d0
    moveq   #0, d7
    move.w  (a0)+,  d0                          ; n tiles in frame (-1)

    ; Offset the tiles for this sprite
	add.w	d5, d5
	lsl.w	#4,	d5
	swap	d5
	add.l	#vdp_vram_tiles, d5
    move.l  d5, vdp_control
    pesf_tile_loop:
        move.l  (a0)+, vdp_data
        dbra    d0, pesf_tile_loop

    rts


; This is a draft to get the logic flowing
******************************************************
* Prepares a sprite frame for VDP
* USE:
* d1: sprite position (in world)
* d2: camera position
* d5: Offset in tiles
* d6: set to sprite state
* a0: set to frame sprites
* 
DrawSpriteFrame:
    move.w  (a0)+, d0
    dsf_sprite_loop:
        move.w  (a0)+,  d7                      ; Holds the offset for this sprite
                                                ; offset is stored as a word as YYXX ... needs some wiggling.

        move.w  d7, d3
        lsr.w   #8, d3

        moveq   #0, d3

        swap    d1                              ; Translate vertical coord by camera to fit in sprite viewport
        swap    d2
        add.w   d1, d3
        sub.w   d2, d3
        add.w   #sprite_view_vmin, d3

        move.w  d3,  vdp_data                   ; Y position sent to VDP

        move.w  (a0)+,  d3                      ; Holds the *size* value for this sprite
        lsl.w   #8, d3
        move.w  d3,  vdp_data                   ; Size and link sent to VDP

        move.w  #65, d3                         ; See if this needs to be h flipped or not
        btst    #sprite_flip_h, d6
        beq.s   dsf_flipped
            or.w    #vram_hflip_bit, d3
        dsf_flipped:
        move.w  d3,  vdp_data                   ; Tile data sent to VDP

        move.w  d7, d3
        andi.w  #$00FF, d3
        moveq   #0, d3
        swap    d1                              ; Translate horizontal coord by camera to fit in sprite viewport
        swap    d2
        add.w   d1, d3
        sub.w   d2, d3
        add.w   #sprite_view_hmin, d3

        move.w  d3,  vdp_data                   ; H position sent to VDP

        * dbra    d0, dsf_sprite_loop
    rts