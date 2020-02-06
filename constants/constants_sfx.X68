; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00004
sfx_driver_size  EQU   $00DE

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $0000+sfx_driver_size
sfx_pewpew       EQU   $0036+sfx_driver_size
sfx_swish        EQU   $008D+sfx_driver_size
sfx_smack        EQU   $00B7+sfx_driver_size
sfx_collect      EQU   $00FB+sfx_driver_size
sfx_playerdead   EQU   $014E+sfx_driver_size
sfx_playerhurt   EQU   $015C+sfx_driver_size
sfx_fanfare      EQU   $016A+sfx_driver_size
sfx_spawn        EQU   $0178+sfx_driver_size

sfx_titletheme   EQU   $0000+sfx_driver_size