; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00004
sfx_driver_size  EQU   $00A4

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $0000+sfx_driver_size
sfx_pewpew       EQU   $0036+sfx_driver_size
sfx_swish        EQU   $008D+sfx_driver_size
sfx_smack        EQU   $00B7+sfx_driver_size
sfx_collect      EQU   $00FB+sfx_driver_size
sfx_playerdead   EQU   $014E+sfx_driver_size
sfx_playerhurt   EQU   $0157+sfx_driver_size
sfx_fanfare      EQU   $0160+sfx_driver_size
sfx_spawn        EQU   $0169+sfx_driver_size

sfx_titletheme   EQU   $0000+sfx_driver_size