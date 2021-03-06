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
* - \3 level tile byte size / 2 for DMA
* - \4 palettes
* -----------------------------------------------
Goto_Level macro
    move.l  #levelstart\@, MEM_level_restart_address
levelstart\@
    lea     NoOpTrap, a6            ; just in case vblank hits while we're getting ready
    lea     \1, a1
    move.l  #\2, d2
    move.w  \3, d1
    lea     \4, a3
    jsr     Init_Level
    lea     Fadein_Level, a6
    move.b  #gamestate_level, (MEM_gamestate)
    jmp     MainLoop
    endm

* -----------------------------------------------
* Go to the bonus level flying through clouds
* -----------------------------------------------
Goto_BonusClouds macro
    jsr     Init_BonusCloudsCard
    lea     MainLoop_BonusCloudsCard, a6
    move.b  #gamestate_bonus_cloud_card, (MEM_gamestate)
    endm

* -----------------------------------------------
* That's all folks
* -----------------------------------------------
Goto_End macro
    jsr     Init_TheEnd
    lea     MainLoop_TheEnd, a6
    move.b  #gamestate_end, (MEM_gamestate)
    endm

; Just in case anything needs to be renamed or added
EndLoop macro
    jmp     MainLoop
    endm