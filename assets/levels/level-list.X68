**********************************************
* Level table to coincide with MEM_next_level
**********************************************

LVL_Queue_ForestDay:
    move.l      #BonusEvents1, MEM_next_bonus_stage
    move.l      #LVL_Queue_ForestNight, MEM_next_level
    move.l      #DayForestThemeBegin, MEM_level_bgm_begin
    move.l      #DayForestThemeEnd-1, MEM_level_bgm_end
    Goto_Level  TestRoom_level, TESTROOM_tiles, #10368, Palettes_TESTROOM
    jmp         next_level_queued

LVL_Queue_ForestNight:
    move.l      #0, MEM_next_bonus_stage
    move.l      #DarkForestThemeBegin, MEM_level_bgm_begin
    move.l      #DarkForestThemeEnd-1, MEM_level_bgm_end
    Goto_Level  ForestNight_Level, TESTROOM_tiles, #10368, ForestNight_Palettes
    jmp         next_level_queued