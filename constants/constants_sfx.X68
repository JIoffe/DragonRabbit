; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00004

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $00C8
sfx_pewpew       EQU   $00FD
sfx_swish        EQU   $014B
sfx_smack        EQU   $0173
sfx_collect      EQU   $01B0
sfx_playerdead   EQU   $01FC 
sfx_playerhurt   EQU   $0205
sfx_fanfare      EQU   $020E 

sfx_titletheme   EQU   $00CA