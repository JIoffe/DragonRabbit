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

    moveq   #0, d0

    print_startline:
        move.l  d7, (a1)
    print_loop:
        move.b  (a0)+, d0
        beq.s   print_string_end

        cmp.b   #CR,   d0
        beq.s   print_endl

        subi.b  #32, d0
        or.w    d6, d0
        move.w  d0, (a2)
        bra.s   print_loop
    print_endl:
        swap    d7
        addi.w  #vdp_plane_byte_width, d7
        swap    d7
        bra.s   print_startline
    print_string_end:
    rts