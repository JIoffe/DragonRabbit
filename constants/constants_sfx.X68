; The var in shared RAM that points to 
; where the z80 should process the current sound
z80_sfx_ptr      EQU   $A00040

; Sound Effect Values (addresses from Z80's perspective)
sfx_boing        EQU   $0065
sfx_pewpew       EQU   $009A
sfx_swish        EQU   $00E8
sfx_smack        EQU   $0110 