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
    move.w  #$7fff,d0
loop\@
    move.w  #$0000, vdp_data
    dbra    d0, loop\@
    endm
