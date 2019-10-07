*-----------------------------------------------------------
* VDP Setup
* (Assumes VDPSetupArray has been defined)
*-----------------------------------------------------------
SetupVDP:
    lea     VDPSetupArray, a0
    move.l  #vdp_register_count, d0     
    vdp_init_loop:
        move.w  (a0)+,vdp_control
        dbf     d0, vdp_init_loop

	ClearVram
