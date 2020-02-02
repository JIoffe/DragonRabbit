; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00004
sfx_driver_size  EQU   $00BE

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $0000+sfx_driver_size
sfx_pewpew       EQU   $0035+sfx_driver_size
sfx_swish        EQU   $0083+sfx_driver_size
sfx_smack        EQU   $00AB+sfx_driver_size
sfx_collect      EQU   $00E8+sfx_driver_size
sfx_playerdead   EQU   $0134+sfx_driver_size
sfx_playerhurt   EQU   $013D+sfx_driver_size
sfx_fanfare      EQU   $0146+sfx_driver_size
sfx_spawn        EQU   $014F+sfx_driver_size

sfx_titletheme   EQU   $0000+sfx_driver_size