*------------------------------
* PALETTES
*------------------------------
* Note that the channels are as follows:
* w: xBGR
* Where each channel can have a value from 0x0 - 0xE (THE MSB IS DISCARDED SO F has NO effect)

* USE: lea of palettes to a0, set number of palettes to load to d0
LoadPalettes:
    lsl.l   #4, d0
    subi.l  #1, d0
    move.l  #vdp_cram_write, vdp_control
    load_palette_loop:
        move.w (a0)+, vdp_data
        dbra    d0, load_palette_loop
        rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
