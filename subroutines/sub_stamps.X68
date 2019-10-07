*==================================================
* Stamps
* - Stamp is a rectangular region of specific tiles
*==================================================
; USE: lea of stamp to a0
;      a1   PLANE Address 
;      d0 - 0xYYXX   tile coordinate
;      d7 - cram palette bits/FLIP/PRIORITY

; d1 - WIDTH
; d2 - HEIGHT

; d3 - COLUMN
; d4 - ROW

; d5 - tile index (as word, running)
DrawStamp:    
    moveq   #0, d1
    moveq   #0, d2
    moveq   #0, d3
    moveq   #0, d6

    move.w  d0, d6                          ; Leave d0 alone in case we're using it somewhere
    move.b  d6, d1                          ; lower byte has XX offset
    andi.w  #$FF00, d6
    lsr.w   #2, d6                          ; upper byte has YY offset, multiplied by 64 is tile offset. net change, 2 bits right
    add.w   d1, d6                          ; add X offset
    add.w   d6, d6                          ; double for byte offset
    swap    d6
    add.l   a1, d6                          ; Add plane offset - now we have the starting address in VRAM

    move.b  (a0)+,  d1                      ; store width and height
    move.b  (a0)+,  d2
    
    subq    #1, d1
    subq    #1, d2
    
    move.w  (a0),   d5                      ; store tile index
    addi.w  #$01,   d5                      ; Add 1 because tileset is offset by 1
    or.w    d7, d5                          ; Apply palette, it can stay there
    
    stamp_loop:
        move.l  d6, vdp_control
        move.w  d1, d3
        s_fill:
            move.w  d5, vdp_data
            addq    #1, d5
            dbra    d3, s_fill

        swap    d6
        add.w   #$0080, d6                  ; Skip to the next row (64 tiles * 2 bytes)
        swap    d6
        dbra    d2, stamp_loop  
    rts

; DRAWS A STAMP FLIPPED HORIZONTALLY
; USE: lea of stamp to a0
;      a1   PLANE Address 
;      d0 - 0xYYXX   tile coordinate
;      d7 - cram palette bits/PRIORITY (HFLIP bit set automatically)
 

; d1 - WIDTH
; d2 - HEIGHT

; d3 - COLUMN
; d4 - Decrementing tile index since we're reversing

; d5 - tile index (as word, running)
DrawStampHFlip:
    or.w    #vram_hflip_bit, d7             ; Automatically set the hflip bit
    moveq   #0, d1
    moveq   #0, d2
    moveq   #0, d3
    moveq   #0, d4
    moveq   #0, d6

    move.w  d0, d6                          ; Leave d0 alone in case we're using it somewhere
    move.b  d6, d1                          ; lower byte has XX offset
    andi.w  #$FF00, d6
    lsr.w   #2, d6                          ; upper byte has YY offset, multiplied by 64 is tile offset. net change, 2 bits right
    add.w   d1, d6                          ; add X offset
    add.w   d6, d6                          ; double for byte offset
    swap    d6
    add.l   a1, d6                          ; Add plane offset - now we have the starting address in VRAM

    move.b  (a0)+,  d1                      ; store width and height
    move.b  (a0)+,  d2
    
    subq    #1, d1
    subq    #1, d2
    
    move.w  (a0),   d5                      ; store tile index
    addi.w  #$01,   d5                      ; Add 1 because tileset is offset by 1
    or.w    d7, d5                          ; Apply palette, it can stay there
    
    stamp_hflip_loop:
        move.l  d6, vdp_control
        move.w  d1, d3
        move.w  d5, d4
        add.w   d1, d4
        s_hflip_fill:
            move.w  d4, vdp_data
            subq    #1, d4
            addq    #1, d5
            dbra    d3, s_hflip_fill

        swap    d6
        add.w   #$0080, d6                  ; Skip to the next row (64 tiles * 2 bytes)
        swap    d6
        dbra    d2, stamp_hflip_loop  
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
