*------------------------------------
* TILES SUBROUTINES
*------------------------------------
* USE lea of tile definition(s) to a0, set d0 to # of tiles
LoadTiles:
	; We *could* use a single loop that goes per each long in a tile
	; but it's possible this can overflow a word
	move.l  #vdp_vram_tiles, vdp_control
	subq	#1, d0
	load_tile_loop:
		moveq	#7, d1
		tile_data_loop:
			move.l 	(a0)+, vdp_data
			dbra	d1, tile_data_loop
		dbra 	d0, load_tile_loop
	rts

* USE lea of tile definition(s) to a0, set d0 to # of tiles, set d1 to offset
LoadTilesOffset:
	WriteVramTilesByTiles d1, d2

	subq	#1, d0
	load_tileoffset_loop:
		moveq	#7, d1
		tileoffset_data_loop:
			move.l 	(a0)+, vdp_data
			dbra	d1, tileoffset_data_loop
		dbra 	d0, load_tileoffset_loop
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
