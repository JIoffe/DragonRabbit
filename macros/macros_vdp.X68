*===============================================================================
* Macros related to VDP and video memory
*===============================================================================
*------------------------------------
* Sends register init commands to VDP
* - \1 = Address of register to load
*------------------------------------
SetVDPRegisters macro
    lea     \1, a0
    move.l  #vdp_register_count, d0     
loop\@
        move.w  (a0)+, vdp_control
        dbra    d0, loop\@
    endm
    
*---------------------------------------
* Clears all VRAM
*---------------------------------------
ClearVram macro
    move.l  #vdp_vram_write, vdp_control
    move.w  #$7fff, d0
loop\@
    move.w  #0, vdp_data
    dbra    d0, loop\@
    endm

*------------------------------------
* Sets BG in CRAM (pal 0, col 0)
* - \1 = COLOR to set
*------------------------------------
SetBG macro
    move.l  #vdp_cram_write, vdp_control
    move.w  \1, vdp_data
    endm


*---------------------------------------
* Sends a VRAM Tile Command
* - \1 register with offset
* - \2 temp register
*---------------------------------------
WriteVramTilesByBytes macro
    ; VRAM commands are a little funky
    ; the last two bits of the address have to be the first 2 bits in the command
	move.w	\1, \2
	andi.w	#$C000, \2		; mask out the last two bits and move them to the front
	rol.w	#2, \2

	andi.w	#$3FFF, \1
	swap	\1
	addi.l	#vdp_vram_tiles, \1
	or.l	\2, \1
    move.l  \1, vdp_control
    endm

*---------------------------------------
* Sends a VRAM Tile Command
* - \1 register with offset
* - \2 temp register
*---------------------------------------
WriteVramTilesByTiles macro
    lsl.w	#5, \1          ; multiply by 32 bytes to get the offset
    WriteVramTilesByBytes \1, \2
    endm