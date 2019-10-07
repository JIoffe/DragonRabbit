*-----------------------------------------------------------
* SEGA LICENSING TMSS
* Must be placed at the start of all files
* Until this is checked, the VDP output will be disabled
*-----------------------------------------------------------
ValidateTMSS:
    * $A14000 is reserved in version 0 and cannot be written to          
    move.b  $A10001,d0
    andi.b  #$0F,d0
    beq.b   version_0
    move.l  #'SEGA',$A14000    
    version_0:
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
