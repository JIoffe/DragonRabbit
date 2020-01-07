* -----------------------------------------------
* Go to the intro scene with the stormy clouds
* -----------------------------------------------
Goto_Licensing macro
    jsr     Init_Licensing
    lea     Loop_Licensing, a6
    move.b  #gamestate_licensing, (MEM_gamestate)
    endm

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
* - \1 level
* - \2 tileset
* - \3 # of tiles
* - \4 palettes
* -----------------------------------------------
Goto_Level macro
    lea     levelstart\@, a0
    move.l  a0, MEM_level_restart_address
levelstart\@
    lea     NoOpTrap, a6            ; just in case vblank hits while we're getting ready
    lea     \1, a1
    lea     \2, a2
    move.w  \3, d1
    lea     \4, a3
    jsr     Init_Level
    lea     Fadein_Level, a6
    move.b  #gamestate_level, (MEM_gamestate)
    jmp     MainLoop
    endm

; Just in case anything needs to be renamed or added
EndLoop macro
    jmp     MainLoop
    endm