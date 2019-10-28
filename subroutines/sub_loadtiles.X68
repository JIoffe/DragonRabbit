*------------------------------------
* TILES SUBROUTINES
*------------------------------------
* USE lea of tile definition(s) to a0, set d0 to # of tiles
LoadTiles:
    lsl.l   #3, d0 ;multiply by 8
    subi.l  #1, d0
    move.l  #vdp_vram_tiles, vdp_control
	load_tile_loop:	
	    move.l 	(a0)+, vdp_data
	    dbra 	d0, load_tile_loop
	    rts

* USE lea of tile definition(s) to a0, set d0 to # of tiles, set d1 to offset
LoadTilesOffset:
    lsl.l   #3, d0 ;multiply by 8
    subi.l  #1, d0
	add.w	d1, d1
	lsl.w	#4,	d1
	swap	d1
	add.l	#vdp_vram_tiles, d1
    move.l  d1, vdp_control
	load_tileo_loop:	
	    move.l 	(a0)+, vdp_data
	    dbra 	d0, load_tileo_loop
	    rts

* USE lea of single tile
; d1 to offset
SetSingleTile:
	lsl.w	#5,	d1
	swap	d1
	add.l	#vdp_vram_tiles, d1
    move.l  d1, vdp_control
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0)+,	vdp_data
	move.l	(a0),	vdp_data
	rts
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
