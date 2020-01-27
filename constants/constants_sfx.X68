; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00040

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $0065
sfx_pewpew       EQU   $009A
sfx_swish        EQU   $00E8
sfx_smack        EQU   $0110
sfx_collect      EQU   $014D
sfx_playerdead   EQU   $0199 
sfx_playerhurt   EQU   $01A2
sfx_fanfare      EQU   $01AB 