******************************************************
* Adds a compound/embedded sprite frame to the VDP.
* Assumes that sprite tile data is in-line
* USE:
* a0: set to frame start
* 
PushEmbeddedSpriteFrame:
    moveq   #0, d1
    move.w  (a0)+, d1
    move.l  a0, d2
    bsr.w   TriggerDMADumpToVRAM
    rts


; This is a draft to get the logic flowing
******************************************************
* Prepares a sprite frame for VDP
* USE:
* d1: sprite position (in world)
* d2: camera position
* d3: temp for writes
* d4: link
* d6: LOWRD - set to sprite state
* d7: keep track of tile offset
* a0: set to frame sprites
* 
DrawSpriteFrame:
        *     dc.w $0003
        * dc.w $00           ; Offset Vertical
        * dc.w $000F           ; sprite Size
        * dc.w $0000           ; sprite tile ID
        * dc.w $0000           ; Offset Horizontal
    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_vmin, d1

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_hmin, d1

    moveq   #0, d0
    move.w  (a0)+,  d0

    move.l  a2, -(SP)
    PointToNextSprite   d4, d3, a2

    btst    #sprite_flip_h, d6
    bne.s   dsf_sprite_loop_flipped                 ; reduce the logic on each iteration
    dsf_sprite_loop:
        move.w  (a0)+, d3
        ext.w   d3
        swap    d1
        add.w   d1, d3
        swap    d1
        move.w  d3, (a2)+                        ; first is y offset

        move.w  (a0)+, d3
        add.w   d4, d3
        addq    #1, d4
        move.w  d3, (a2)+                        ; second is size and link

        move.w  d7, d3
        add.w   (a0)+, d3
        move.w  d3, (a2)+                        ; third is tile ID + priority/h flip/v flip

        move.w  (a0)+, d3
        andi.w  #$00FF,d3
        ext.w   d3                                  ; extend polarity for negative offsets
        add.w   d1, d3
        move.w  d3, (a2)+                        ; last is x offset
        dbra    d0, dsf_sprite_loop
    move.l (SP)+, a2
    rts

    dsf_sprite_loop_flipped:
        move.w  (a0)+, d3
        ext.w   d3
        swap    d1
        add.w  d1, d3
        swap    d1
        move.w  d3, (a2)+                        ; first is y offset

        move.w  (a0)+, d3
        add.w   d4, d3
        addq    #1, d4
        move.w  d3, (a2)+                        ; second is size and link

        move.w  d7, d3
        add.w   (a0)+, d3
        or.w    #vram_hflip_bit, d3
        move.w  d3, (a2)+                        ; third is tile ID + priority/h flip/v flip

        move.w  (a0)+, d3
        lsr.w   #8, d3
        ext.w   d3                                  ; extend polarity for negative offsets
        add.w   d1, d3
        move.w  d3, (a2)+                        ; last is x offset
        dbra    d0, dsf_sprite_loop_flipped

    move.l (SP)+, a2
    rts

* Prepares a single sprite (up to 4x4) for VDP
* USE:
* d1: sprite position (in world)
* d2: camera position
* d3: temp for writes
* d4: link
* d6: LOWRD - set to sprite state
* d7: keep track of tile offset
* a0: set to frame sprites
* 
DrawSprite:
    move.l a2, -(SP)
    PointToNextSprite   d4, d3, a2
    
    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_vmin, d1
    move.w  d1, (a2)+                           ; first is y offset

    move.w  (a0)+, d3
    add.w   d4, d3
    addq    #1, d4
    move.w  d3, (a2)+                           ; second is size and link

    move.w  d7, d3
    add.w   (a0)+, d3
    move.w  d3, (a2)+                           ; third is tile ID + priority/h flip/v flip

    swap    d1
    swap    d2
    sub.w   d2, d1
    add.w   #sprite_view_hmin, d1
    move.w  d1, (a2)                            ; last is x offset

    move.l (SP)+, a2

    rts

* Prepares a single sprite (up to 4x4) for VDP
* USE:
* d1: sprite position (in sprite viewport coordinates)
* d3: temp for writes
* d4: link
* d7: keep track of tile offset
* a0: set to frame sprites
* d1,d3 - trashed
DrawSprite_Untransformed:
    move.l a2, -(SP)
    PointToNextSprite   d4, d3, a2

    swap    d1
    move.w  d1, (a2)+                        ; first is y offset

    move.w  (a0)+, d3
    add.w   d4, d3
    addq    #1, d4
    move.w  d3, (a2)+                        ; second is size and link

    move.w  d7, d3
    add.w   (a0)+, d3
    move.w  d3, (a2)+                        ; third is tile ID + priority/h flip/v flip

    swap    d1
    move.w  d1, (a2)                        ; last is x offset
    move.l (SP)+, a2
    rts