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

* USE: lea of palettes to a0
* set number of palettes to load to d0
* set offset to d1
LoadPaletteOffset:
    moveq   #0, d7
    move.b  d1, d7
    lsl.l   #5, d7
    swap    d7
    add.l   #vdp_cram_write, d7
    move.l  d7, vdp_control
    load_palette_o_loop:
        move.w (a0)+, vdp_data
        dbra    d0, load_palette_o_loop
        rts

* USE: set d0 to the fade amount of the palette
*      lea of palette to a0
FadePalette:
    moveq   #0, d6
    moveq   #7, d7
    move.l  #vdp_cram_write, vdp_control
    fp_l1:
        move.w  (a0)+, d6
        and.w   d0, d6
        move.w  d6, vdp_data
        dbra    d7, fp_l1

    moveq   #7, d7
    fp_l2:
        move.w  (a0)+, d6
        and.w   d0, d6
        move.w  d6, vdp_data
        dbra    d7, fp_l2

    rts
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
