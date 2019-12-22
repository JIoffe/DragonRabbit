*------------------------------------
* TILES SUBROUTINES
*------------------------------------
DMAUncompressedTiles:
	rts
* Spits uncompressed tiles directly into VRAM
* DMAUncompressedTiles:
* 	DMA68KtoVRAM	4080, Tiles_intro_storm, $20
* 	* move.w	#$9300+((4080>>1)&$FF), vdp_control               ; Lo Byte of length
* 	* move.w	#$94F0+((4080>>1)&$FF00>>8), vdp_control          ; Hi byte of length

* 	* move.w  #$9300+((Tiles_intro_storm>>1)&$FF), vdp_control               ; Src Address
* 	* move.w  #$9400+(((Tiles_intro_storm>>1)&$FF00)>>8), vdp_control
* 	* move.w  #$9500+((Tiles_intro_storm>>1)&$FF), vdp_control
* 	* move.w  #$9600+(((Tiles_intro_storm>>1)&$FF00)>>8), vdp_control
* 	* move.w  #$9700+(((Tiles_intro_storm>>1)&$7F0000)>>16), vdp_control

*     * ; Set destination and trigger DMA
* 	* move.l  #$40000080+(($20&$3FFF)<<16)+(($20&$C000)>>14), vdp_control
* 	rts

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
