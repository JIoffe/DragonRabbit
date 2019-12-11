* -----------------------------------------------
* Clamp camera so it does not extend beyond level
* -----------------------------------------------
; \1 - Register with camera position
; \2 - Register to hold level height
; \3 - Register to hold level width 
; - assumes a0 holds level data (size)

ClampCameraToLevel macro
    ; compare camera to level height
    move.w  (a0)+, \2
    move.w  (a0)+, \3

    asl.w   #3, \2
    asl.w   #3, \3

    swap    \1
    sub.w   #vdp_screen_height, \2
    cmp.w   \2, \1
    ble.s   check_y_min\@
        move.w  \2, \1
        bra.s   checked_y\@
check_y_min\@
    tst     \1                        ; if negative bit, clamp to zero
    bpl.s   checked_y\@
        move.w  #0, \1
checked_y\@
    swap    \1

    ; now check extents horizontally (x)

    ; check level width
    sub.w   #vdp_screen_width, \3
    cmp.w   \3, \1
    ble.s   check_x_min\@
        move.w  \3, \1
        bra.s   checked_x\@
check_x_min\@
    tst     \1
    bpl.s   checked_x\@
        move.w  #0, \1                ; likewise, if negative clamp to zero
checked_x\@
    endm

* -----------------------------------------------
* Clamp camera to bounding box around player
* -----------------------------------------------
; \1 - Register with camera position
; \2 - Register with player position

ClampCameraToPlayer macro
    ; Lock camera to box around player
    move.w  \2, d7
    sub.w   #camera_zone_hmax, d7
    cmp.w   \1, d7
    ble.s   lvl_cam_check_left\@
        move.w  d7, \1
        bra.s   lvl_cam_lr_checked\@
lvl_cam_check_left\@
    move.w  \2, d7
    sub.w   #camera_zone_hmin, d7
    cmp.w   \1, d7
    bge.s   lvl_cam_lr_checked\@
        move.w  d7, \1
lvl_cam_lr_checked\@

    swap    \2
    swap    \1

    move.w  \2, d7
    sub.w   #camera_zone_vmax, d7
    cmp.w   \1, d7
    ble.s   lvl_cam_check_up\@
        move.w  d7, \1
        bra.s   lvl_cam_ud_checked\@
lvl_cam_check_up\@
    move.w  \2, d7
    sub.w   #camera_zone_vmin, d7
    cmp.w   \1, d7
    bge.s   lvl_cam_ud_checked\@
        move.w  d7, \1
lvl_cam_ud_checked\@

    swap    \2
    swap    \1
    endm

* -----------------------------------------------
* Fills visible camera frame with level data
* -----------------------------------------------
; \1 - Register with camera
; \2 - y Loop counter
FillCameraFrame macro
    moveq   #0, d2
    moveq   #0, d3
    move.w  (a0)+, d2                       ; Level Height
    move.w  (a0)+, d3                       ; Level Width


    ; Rough way of filling the frame with the right tiles given our starting scroll
    ; Start with moving into our data based on the camera offset
    moveq   #0, d0
    swap    \1
    move.w  \1, d0
    lsr.w   #3, d0
    mulu.w  d3, d0

    swap    \1
    move.w  \1, \2
    lsr.w   #3, \2
    add.w   \2, d0
    add.l   d0, d0
    add.l   d0, a0

    sub.w   #vdp_visible_tile_width,   d3                   ; difference between level width and plane width
    add.l   d3, d3                                          ; tiles * 2 byte offset to skip rows in the level data

    ; Then camera offset will be used to determine where in VRAM we write to
    lsr.w   #3, \1
    swap    \1
    lsr.w   #3, \1

    move.w  #vdp_visible_tile_height-1, \2
fill_frame_y\@
        move.w  #vdp_visible_tile_height-1, d6
        sub.w   \2, d6
        add.w   \1, d6
        andi.w  #vdp_plane_tile_height-1, d6
        lsl.w   #6, d6

        swap    \1
        move.w  #vdp_visible_tile_width-1, d0
fill_frame_x\@
            moveq   #0, d7
            move.w  d6, d7

            move.w  #vdp_visible_tile_width-1, d4
            sub.w   d0, d4
            add.w   \1, d4
            andi.w  #vdp_plane_tile_width-1, d4

            add.w   d4, d7
            add.w   d7, d7
            swap    d7
            addi.l  #vdp_write_plane_a, d7
            move.l  d7, vdp_control
            move.w  (a0)+, vdp_data
            dbra    d0, fill_frame_x\@

        add.l   d3, a0
        swap    \1
        dbra    \2, fill_frame_y\@
    endm
* -----------------------------------------------
* Advances pointer to location in level data that matches camera
* -----------------------------------------------
SeekLevelData   macro
    ; advance level pointer by camera position
    swap    d2
    move.w  d2, d0
    lsr.w   #3, d0
    mulu.w  d4, d0
    add.w   d4, d4                          ; double for byte offset

    swap    d2
    move.w  d2, d7
    lsr.w   #3, d7
    add.w   d7, d0
    add.l   d0, d0
    add.l   d0, a0
    endm
* -----------------------------------------------
* Fills in columns based on x camera movement
* -----------------------------------------------
; assumptions:
; a1 holds level data
; d2 holds camera position
; d5 holds camera position in previous frame
StreamLevelColumns  macro
    move.l  a1, a0
    move.w  (a0)+, d3                       ; Level Height
    moveq   #0, d4
    move.w  (a0)+, d4                       ; Level Width
    move.l  a0, a2                          ; save start of level data

    moveq   #0, d0
    moveq   #0, d6

    sub.w   d2, d5
    bmi.s   stream_column_right             ; previous is less - moving right
        lsr.w   #3, d5                      
        stream_columns_l:
            ; advance level pointer by camera position and column offset
            swap    d2
            move.w  d2, d6
            lsr.w   #3, d6
            mulu.w  d4, d6

            swap    d2
            move.w  d2, d7
            lsr.w   #3, d7
            add.w   d5, d7
            subq    #1, d7
            add.w   d7, d6
            add.w   d6, d6
            move.l  a2, a0
            add.l   d6, a0

            move.w  #vdp_visible_tile_height, d0
            stream_column_fill_l:
                moveq   #0, d7
                move.w  d2, d7
                lsr.w   #3, d7
                add.w   #vdp_plane_tile_width, d7
                add.w   d5, d7
                subq    #1, d7
                andi.w  #vdp_plane_tile_width-1, d7         ; x coord

                swap    d2
                move.w  d2, d6
                swap    d2
                lsr.w   #3, d6
                addi.w  #vdp_visible_tile_height, d6
                sub.w   d0, d6
                andi.w  #vdp_plane_tile_height-1, d6        ; y coord
                asl.w   #6, d6                              ; y coord offfset
                add.w   d6, d7

                add.w   d7, d7
                swap    d7
                addi.l  #vdp_write_plane_a, d7

                move.l  d7, vdp_control
                move.w  (a0), vdp_data
                add.l   d4, a0
                add.l   d4, a0
                dbra    d0, stream_column_fill_l
            dbra    d5,  stream_columns_l
        bra.s   stream_column_done
    stream_column_right:
        neg     d5
        lsr.w   #3, d5
        addq    #1, d5
        stream_columns_r:
            ; advance level pointer by camera position and column offset
            swap    d2
            move.w  d2, d6
            lsr.w   #3, d6
            mulu.w  d4, d6

            swap    d2
            move.w  d2, d7
            lsr.w   #3, d7
            add.w   d5, d7
            subq    #1, d7
            addi.w  #vdp_visible_tile_width, d7
            add.w   d7, d6
            add.w   d6, d6
            move.l  a2, a0
            add.l   d6, a0

            move.w  #vdp_visible_tile_height, d0
            stream_column_fill_r:
                moveq   #0, d7
                move.w  d2, d7
                lsr.w   #3, d7
                add.w   #vdp_visible_tile_width, d7
                add.w   d5, d7
                subq    #1, d7
                andi.w  #vdp_plane_tile_width-1, d7         ; x coord

                swap    d2
                move.w  d2, d6
                swap    d2
                lsr.w   #3, d6
                addi.w  #vdp_visible_tile_height, d6
                sub.w   d0, d6
                andi.w  #vdp_plane_tile_height-1, d6        ; y coord
                asl.w   #6, d6                              ; y coord offfset
                add.w   d6, d7

                add.w   d7, d7
                swap    d7
                addi.l  #vdp_write_plane_a, d7

                move.l  d7, vdp_control
                move.w  (a0), vdp_data
                add.l   d4, a0
                add.l   d4, a0
                dbra    d0, stream_column_fill_r
            dbra    d5,  stream_columns_r
    stream_column_done:
    endm

StreamLevelRows  macro
    ; stream rows vertically

    move.l  a1, a0
    move.w  (a0)+, d3                       ; Level Height
    moveq   #0, d4
    move.w  (a0)+, d4                       ; Level Width
    move.l  a0, a2                          ; save start of level data

    moveq   #0, d0
    moveq   #0, d6

    swap    d2                              ; swap to compare Y delta
    swap    d5
    sub.w   d2, d5
    bmi.s   stream_row_down                 ; previous is less - moving DOWN (positive Y)
        swap    d2
        lsr.w   #3, d5                      
        stream_row_up:
            ; advance level pointer by camera position and column offset
            swap    d2
            move.w  d2, d6
            lsr.w   #3, d6
            add.w   d5, d6
            mulu.w  d4, d6

            swap    d2
            move.w  d2, d7
            lsr.w   #3, d7
            add.w   d7, d6
            add.w   d6, d6
            move.l  a2, a0
            add.l   d6, a0

            move.w  #vdp_visible_tile_width, d0
            stream_row_fill_up:
                moveq   #0, d7
                move.w  d2, d7
                lsr.w   #3, d7
                addi.w  #vdp_visible_tile_width, d7
                sub.w   d0, d7
                andi.w  #vdp_plane_tile_width-1, d7         ; x coord

                swap    d2
                move.w  d2, d6
                swap    d2
                lsr.w   #3, d6
                add.w   d5, d6
                andi.w  #vdp_plane_tile_height-1, d6        ; y coord
                asl.w   #6, d6
                add.w   d6, d7

                add.w   d7, d7
                swap    d7
                addi.l  #vdp_write_plane_a, d7

                move.l  d7, vdp_control
                move.w  (a0)+, vdp_data
                dbra    d0, stream_row_fill_up
            dbra    d5,  stream_row_up
        bra.s   stream_row_done
    stream_row_down:
        swap    d2
        neg     d5
        lsr.w   #3, d5                      
        stream_row_down_loop:
            ; advance level pointer by camera position and column offset
            swap    d2
            move.w  d2, d6
            lsr.w   #3, d6
            add.w   d5, d6
            add.w   #vdp_visible_tile_height, d6
            mulu.w  d4, d6

            swap    d2
            move.w  d2, d7
            lsr.w   #3, d7
            add.w   d7, d6
            add.w   d6, d6
            move.l  a2, a0
            add.l   d6, a0

            move.w  #vdp_visible_tile_width, d0
            stream_row_fill_down:
                moveq   #0, d7
                move.w  d2, d7
                lsr.w   #3, d7
                addi.w  #vdp_visible_tile_width, d7
                sub.w   d0, d7
                andi.w  #vdp_plane_tile_width-1, d7         ; x coord

                swap    d2
                move.w  d2, d6
                swap    d2
                lsr.w   #3, d6
                add.w   d5, d6
                add.w   #vdp_visible_tile_height, d6
                andi.w  #vdp_plane_tile_height-1, d6        ; y coord
                asl.w   #6, d6
                add.w   d6, d7

                add.w   d7, d7
                swap    d7
                addi.l  #vdp_write_plane_a, d7

                move.l  d7, vdp_control
                move.w  (a0)+, vdp_data
                dbra    d0, stream_row_fill_down
            dbra    d5,  stream_row_down_loop
    stream_row_done:
    endm

StreamLevelForCamera    macro
    StreamLevelColumns
    StreamLevelRows
    endm

***********************************
* Jumps to a failure case if a box is not in view of the camera
* \1 - failure label
* \2 - Camera Position
* \3 - Box Start
* \4 - Box Size
* \5 - Register for temp
CancelOutOfView     macro
    ; check if upper left corner is beyond the bottom right edge of the screen
    move.l  \2, \5
    addi.l  #vdp_screen_max, \5
    sub.l   \3, \5
    bmi.s   checkfailed\@
    tst.w   \5
    bmi.s   checkfailed\@

    ; check if lower right corner is beyond the top left edge of the screen
    move.l  \2, \5
    sub.l   \3, \5
    subi.l  \4, \5
    bpl.s   checkfailed\@
    tst.w   \5
    bpl.s   checkfailed\@

    bra.s   checkpassed\@
checkfailed\@
    bra.w   \1
checkpassed\@
    endm