* -----------------------------------------------
* Go to the intro scene with the stormy clouds
* -----------------------------------------------
Goto_IntroClouds macro
    jsr     Init_IntroClouds
    lea     MainLoop_Clouds, a6
    move.b  #gamestate_intro, (MEM_gamestate)
    endm

* -----------------------------------------------
* Move to title screen that leads to gameplay
* -----------------------------------------------
Goto_Title macro
    jsr     Init_Title
    lea     MainLoop_Title, a6
    move.b  #gamestate_title, (MEM_gamestate)
    endm

* -----------------------------------------------
* Move to a level
* - \1 is the label of the level to go to
* -----------------------------------------------
Goto_Level macro
    lea     \1, a1
    jsr     Init_Level
    lea     MainLoop_Level, a6
    move.b  #gamestate_level, (MEM_gamestate)   
    endm

; Just in case anything needs to be renamed or added
EndLoop macro
    jmp     MainLoop
    endm