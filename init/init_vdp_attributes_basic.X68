*===============================
* VDP Registers Array
*===============================
* ---------------------------------------------------------
* Write Only
* - Most Significant Byte is the register index + 128
* - Least significant byte is the actual data
* ---------------------------------------------------------

*Tile plane addresses are turned into attributes thusly:
vdp_attr_plane_a    EQU $8200+(vdp_vram_plane_a_addr>>10)
vdp_attr_window     EQU $8300+(vdp_vram_window_addr>>10)
vdp_attr_plane_b    EQU $8400+(vdp_vram_plane_b_addr>>13)

VDPSetupArray:
	dc.w    $8004               ;9Bit Color mode, disable horizontal interrupts
	dc.w    $8174               ;Genesis mode, Enable DMA and VBlank	
	dc.w    vdp_attr_plane_a    ;Plane A nametable address 
	dc.w    vdp_attr_window	    ;window nametable address
	dc.w    vdp_attr_plane_b    ;Plane B nametable address
	dc.w    $855C	            ;sprite
	dc.w    $8600
	dc.w    $8700               ;BG color (0th slot)		
	dc.w    $8800
	dc.w    $8900
	dc.w    $8AFF	            ;hblanks off	
	dc.w    $8B00               ;Full screen scroll
	dc.w    $8C81	            ;320 pixel / 40 cell mode
	dc.w    $8D2F		
	dc.w    $8E00
	dc.w    $8F02	            ;auto increment	on every VDP r/w
	dc.w    $9001		        ;64 x 32 cells each plane
	dc.w    $9100		
	dc.w    $9200
	dc.w	$93FF
	dc.w	$94FF
	dc.w	$9500
	dc.w	$9600
	dc.w	$9780               ;DMA mode is RAM -> VRAM


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
