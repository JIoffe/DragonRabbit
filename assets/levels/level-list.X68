**********************************************
* Level table to coincide with MEM_next_level
**********************************************

LVL_Queue_ForestDay:
    move.l      #BonusEvents1, MEM_next_bonus_stage
    move.l      #LVL_Queue_ForestNight, MEM_next_level
    Goto_Level  TestRoom_level, TESTROOM_tiles, #10368, Palettes_TESTROOM
    jmp         next_level_queued

LVL_Queue_ForestNight:
    move.l      #0, MEM_next_bonus_stage
    Goto_Level  ForestNight_Level, TESTROOM_tiles, #10368, ForestNight_Palettes
    jmp         next_level_queued