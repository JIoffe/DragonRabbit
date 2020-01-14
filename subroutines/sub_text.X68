*******************************************************************
* Prints a null-terminated string to a specified plane without DMA
* -----------------------------------------------------------------
*  a0 - null terminated string to print
*  d0 - trashed
*  d6 - bits
*  d7 - VRAM command / trashed
*  a1-a2 - trashed
*******************************************************************
PrintStringNoDMA:
    lea.l   vdp_control, a1
    lea.l   vdp_data, a2   

    print_startline:
        move.l  d7, (a1)
    print_loop:
        moveq   #0, d0
        move.b  (a0)+, d0
        beq.s   print_string_end

        cmp.b   #CR,   d0
        beq.s   print_endl

        subi.b  #32, d0
        beq.s   print_adjust_skip
            add.w   d6, d0
        print_adjust_skip:
        move.w  d0, (a2)
        bra.s   print_loop
    print_endl:
        swap    d7
        addi.w  #vdp_plane_byte_width, d7
        swap    d7
        bra.s   print_startline
    print_string_end:
    rts

*************************************************************
* Long name but... prints letters falling to a target height
* Given a frame count and letter offset
* a0 - null terminated string
* d1 - target position
* d2 - offset between letters
* d5 - tile offset/flags
* d6 - amount to advance from top
PrintFallingTextAsSprites:
    swap    d1
    move.w  d1, a5
    move.w  d6, d1
    addi.w  #sprite_view_vmin, d1
    swap    d1
    printfalling_text_sprite_loop:
        add.l   d2, d1
        moveq   #0, d3
        move.b  (a0)+, d3
        beq.s   printfalling_sprite_end

        sub.b   #32, d3
        beq.s   printfalling_text_sprite_loop

        swap    d1
        move.w  d1, d6
        swap    d1
        cmp.w   a5, d6
        ble.s   printfalling_limited
            move.w  a5, d6
        printfalling_limited:
        move.w  d6, (a2)+                                                   ; y offset

        move.w  d4, (a2)+                                                   ; size and link
        addq    #1, d4
        add.w   d5, d3
        move.w  d3, (a2)+         ; tile id / flags
        move.w  d1, (a2)+                                                 ; x offset
        bra.s   printfalling_text_sprite_loop
        printfalling_sprite_end:
    rts

*************************************************************
* Long name but... prints letters falling to a target height
* Given a frame count and letter offset
* a0 - null terminated string
* d1 - target position
* d5 - tile offset/flags
PrintTextAsSprites:
    print_text_sprite_loop:
        addq    #8, d1
        moveq   #0, d3
        move.b  (a0)+, d3
        beq.s   print_sprite_end

        sub.b   #32, d3
        beq.s   print_text_sprite_loop

        swap    d1
        move.w  d1, (a2)+                                                   ; y offset
        swap    d1
        move.w  d4, (a2)+                                                   ; size and link
        addq    #1, d4
        add.w   d5, d3
        move.w  d3, (a2)+         ; tile id / flags
        move.w  d1, (a2)+                                                 ; x offset
        bra.s   print_text_sprite_loop
        print_sprite_end:
    rts