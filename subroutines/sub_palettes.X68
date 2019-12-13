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

* USE: set a0 to palette to fade
* d0: number of palettes to load
* d1: fade amount
* d2-d4: temp used for writes
FadePalettes:
    lsl.l   #4, d0
    subi.l  #1, d0
    move.l  #vdp_cram_write, vdp_control
    fade_load_palette_loop:
        move.w  (a0)+, d2

        ; Fade each channel
        ; RED
        move.w  d2, d3
        andi.w  #$000F, d3
        sub.w   d1, d3
        ClampToZero d3
        move.w  d3, d4

        ; GREEN
        move.w  d2, d3
        lsr.w   #4, d3
        andi.w  #$000F, d3
        sub.w   d1, d3
        ClampToZero d3
        lsl.w   #4, d3
        or.w    d3, d4

        * ; BLUE
        move.w  d2, d3
        lsr.w   #8, d3
        andi.w  #$000F, d3
        sub.w   d1, d3
        ClampToZero d3
        lsl.w   #8, d3
        or.w    d3, d4 

        move.w  d4, vdp_data
        dbra    d0, fade_load_palette_loop
        rts

ClearCRAM:
    move.l  #vdp_cram_write, vdp_control
    moveq   #0, d0
    move.w  #63, d0
    clear_cram_loop:
        move.w  #0, vdp_data 
        dbra    d0, clear_cram_loop
    rts