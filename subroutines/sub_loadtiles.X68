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
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
