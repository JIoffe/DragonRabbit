*===============================================================================
* Macros related to scrolling sideways, and upways, and all kinds of ways!
*===============================================================================
*------------------------------
* Sends VDP command to adjust ScrollH from a specific tile row converted to lines
* - \1 = Number of rows
*------------------------------
VDPcmdScrollTilesH macro
    move.l  \1, d0
    ; Multiply by 4 because 4 bytes per line
    add.w   d0, d0
    add.w   d0, d0
    ; multiply by 8 because 8 lines per tile
    lsl.w   #3, d0
    ; swap to get it into the memory bitmask for vdp commands
    swap    d0
    addi.l  #vdp_vram_hscroll, d0
    move.l  d0, vdp_control
    endm

*------------------------------
*Scroll (n) Lines Horizontally:
* - \1 = Number of lines
* - \2 = Scroll Amount Plane A
* - \3 = Scroll Amount Plane B
*------------------------------
scrollLinesH macro           
    move.l  \1, d0
loop\@
    move.w  \2, vdp_data
    move.w  \3, vdp_data
    dbra    d0, loop\@
    endm