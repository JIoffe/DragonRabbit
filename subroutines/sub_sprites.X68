******************************************************
* Adds a compound/embedded sprite frame to the VDP.
* Assumes that sprite tile data is in-line
* USE:

* d5: Offset in bytes to write to tile vram
* a0: set to frame start
* 
PushEmbeddedSpriteFrame:
    move.w  (a0)+,  d0                          ; n tiles in frame (-1)

    ; Offset the tiles for this sprite
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
* d3: temp for writes
* d4: link
* d6: LOWRD - set to sprite state
* d7: keep track of tile offset
* a0: set to frame sprites
* 
DrawSpriteFrame:
        *     dc.w $0003
        * dc.w $00           ; Offset Vertical
        * dc.w $000F           ; sprite Size
        * dc.w $0000           ; sprite tile ID
        * dc.w $0000           ; Offset Horizontal

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_vmin, d1

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_hmin, d1

    moveq   #0, d0
    move.w  (a0)+,  d0

    btst    #sprite_flip_h, d6
    bne.s   dsf_sprite_loop_flipped                 ; reduce the logic on each iteration
    dsf_sprite_loop:
        move.w  (a0)+, d3
        ext.w   d3
        swap    d1
        add.w  d1, d3
        swap    d1
        move.w  d3, vdp_data                        ; first is y offset

        move.w  (a0)+, d3
        add.w   d4, d3
        addq    #1, d4
        move.w  d3, vdp_data                        ; second is size and link

        move.w  d7, d3
        add.w   (a0)+, d3
        move.w  d3, vdp_data                        ; third is tile ID + priority/h flip/v flip

        move.w  (a0)+, d3
        andi.w  #$00FF,d3
        ext.w   d3                                  ; extend polarity for negative offsets
        add.w   d1, d3
        move.w  d3, vdp_data                        ; last is x offset
        dbra    d0, dsf_sprite_loop
    rts

    dsf_sprite_loop_flipped:
        move.w  (a0)+, d3
        ext.w   d3
        swap    d1
        add.w  d1, d3
        swap    d1
        move.w  d3, vdp_data                        ; first is y offset

        move.w  (a0)+, d3
        add.w   d4, d3
        addq    #1, d4
        move.w  d3, vdp_data                        ; second is size and link

        move.w  d7, d3
        add.w   (a0)+, d3
        or.w    #vram_hflip_bit, d3
        move.w  d3, vdp_data                        ; third is tile ID + priority/h flip/v flip

        move.w  (a0)+, d3
        lsr.w   #8, d3
        ext.w   d3                                  ; extend polarity for negative offsets
        add.w   d1, d3
        move.w  d3, vdp_data                        ; last is x offset
        dbra    d0, dsf_sprite_loop_flipped

    rts