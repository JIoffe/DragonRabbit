******************************************************
* Adds a compound/embedded sprite frame to the VDP.
* Assumes that sprite tile data is in-line
* USE:
* d1: Offset in bytes to write to tile vram
* a0: set to frame start
* 
PushEmbeddedSpriteFrame:
    moveq   #0, d0
    moveq   #0, d2
    moveq   #0, d7
    move.w  (a0)+,  d0                          ; n tiles in frame (-1)

    ; Offset the tiles for this sprite
	add.w	d1, d1
	lsl.w	#4,	d1
	swap	d1
	add.l	#vdp_vram_tiles, d1
    move.l  d1, vdp_control
    pesf_tile_loop:
        move.l  (a0)+, vdp_data
        dbra    d0, pesf_tile_loop

    * lsl.l   #3, d0
    * move.l  d0, d5
    * swap    d5
    * add.l   #vdp_vram_sprite, d5
    * move.l  d5, vdp_control
    * move.w  d1, vdp_data
    
    * addq    #4, d0
    * swap    d0
    * add.l   #vdp_vram_sprite, d0
    * move.l  d0, vdp_control
    * move.w  d2, vdp_data
    * swap    d1
    * move.w  d1, vdp_data
    rts
