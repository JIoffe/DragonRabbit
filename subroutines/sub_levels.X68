*------------------------------
* Levels / Tile Plans
*------------------------------

**********************************************************
* Fills the frame with level tiles given a camera location
**********************************************************
; a0 - lea of level data
; d1 - loop counter
; d2 - Level Height (in tiles)
; d3 - Level width (in tiles)
; d5 - level data pointer
; d7 - camera position
Level_FillFrame:
    move.l  #vdp_visible_tile_height-1, d1

    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2
    move.w  (a0)+, d3


    ; Advance data pointer by camera offset
    moveq   #0, d5
    moveq   #0, d0
    move.w  d7, d5
    lsr.w   #3, d5

    swap    d7
    move.w  d7, d0
    lsr.w   #3, d0
    mulu.w  d3, d0
    add.l   d5, d0
    add.l   d0, d0
    add.l   d0, a0

    sub.w   #vdp_visible_tile_width,   d3                   ; difference between level width and plane width
    add.l   d3, d3                                          ; tiles * 2 byte offset to skip rows in the level data


    move.l  #vdp_write_plane_a, d5
    framefill_loop:
        move.l  d5, vdp_control
        move.l  #vdp_visible_tile_width-1, d0               ; plane width is 64 tiles
        lff_fill:
            move.w  (a0)+, vdp_data
            dbra    d0, lff_fill

        add.l   d3, a0                                      ; Advance level data pointer

        swap    d5
        addi.w  #vdp_plane_byte_width,  d5                  ; Advance vdp command pointer
        swap    d5

        dbra    d1, framefill_loop 
    rts


***************************************************************
* Copies a pattern to a plane at the specified tile coordinate
***************************************************************
; a0 - lea of level data
; d5 - LOWORD - tile offset to add (to non-zero index), HIWORD - YYXX tile offset
; d2 - Level Height (in tiles)
; d3 - Level width (in tiles)
; d4 - Level rowskip (d3 * 2);
; a5 - PLANE TO DRAW TO
Plane_DrawPattern:
    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2
    move.w  (a0)+, d3

    moveq   #0, d1
    move.w  d2, d1
    subq    #1, d1
    subq    #1, d3

    ; Add locational offset
    swap    d5
    moveq   #0, d0
    move.b  d5, d0          ; x offset

    moveq   #0, d7
    move.w  d5, d7
    andi.w  #$FF00, d7
    lsr.w   #2, d7          ; y offset

    add.w   d0, d7
    add.w   d7, d7
    swap    d5
    swap    d7
    add.l   a5, d7

    patternfill_loop:
        move.l  d7, vdp_control
        move.w  d3, d0
        pf_fill:
            move.w  (a0)+, d6
            tst.w   d6
            beq.s   pf_adjusted
            add.w   d5, d6
            pf_adjusted:
            move.w  d6, vdp_data
            dbra    d0, pf_fill

        swap    d7
        addi.w  #vdp_plane_byte_width,  d7                  ; Advance vdp command pointer
        swap    d7

        dbra    d1, patternfill_loop

    rts

***************************************************************
* Copies a flipped H pattern to a plane at the specified tile coordinate
***************************************************************
; a0 - lea of level data
; d5 - LOWORD - tile offset to add (to non-zero index), HIWORD - YYXX tile offset
; d2 - Level Height (in tiles)
; d3 - Level width (in tiles)
; d4 - Level rowskip (d3 * 2);
Plane_DrawPatternFlipH:
    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2
    move.w  (a0)+, d3

    moveq   #0, d1
    move.w  d2, d1
    subq    #1, d1

    ; Add locational offset
    swap    d5
    moveq   #0, d0
    move.b  d5, d0          ; x offset

    moveq   #0, d7
    move.w  d5, d7
    andi.w  #$FF00, d7
    lsr.w   #2, d7          ; y offset

    add.w   d0, d7
    add.w   d7, d7
    swap    d5
    swap    d7
    add.l   a5, d7

    ; Going in reverse...
    ; Move ahead with the pointer and go backwards
    move.w  d3, d0
    add.w   d0, d0      ; double for byte offset
    add.l   d0, a0

    subq    #1, d3      ; prepare for loops

    patternfillhf_loop:
        move.l  d7, vdp_control
        move.w  d3, d0
        pf_fillhf:
            move.w  -(a0), d6
            tst.w   d6
            beq.s   pf_adjustedhf
            add.w   d5, d6
            pf_adjustedhf:
            eor.w    #vram_hflip_bit, d6
            move.w  d6, vdp_data
            dbra    d0, pf_fillhf

        ; After each row, advance by twice the width
        move.w  d3, d0
        add.w   d0, d0
        add.w   d0, d0
        addq    #4, d0
        add.l   d0, a0

        swap    d7
        addi.w  #vdp_plane_byte_width,  d7                  ; Advance vdp command pointer
        swap    d7

        dbra    d1, patternfillhf_loop

    rts

***************************************************************
* Sets an entire plane to use tile index 0
***************************************************************
; set a0 to plane address
ClearPlane:
    move.l  a0, vdp_control
    moveq   #0, d0
    move.w  #2047, d0
    clp_loop:
        move.w  #0, vdp_data
        dbra    d0, clp_loop
    rts

FadeOutLevelPalettes:
    move.w  (frame_counter), d5
    moveq   #0, d1
    move.b  (MEM_fade), d1

    cmp.b   #$0E, d1
    beq.s   lvl_fadeout_advance
    andi.w  #lvl_fadein_interval, d5
    bne.s   lvl_fadeout_advance
        addi.b  #2, d1
        move.b  d1, (MEM_fade)
    lvl_fadeout_advance:

    move.l  MEM_palette, a0
    moveq   #4, d0
	bsr.w   FadePalettes
    rts