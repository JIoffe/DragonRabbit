**********************************************
* Level table to coincide with MEM_next_level
**********************************************

LVL_Queue_ForestDay:
    move.l      #0, MEM_level_post_init_handler
    move.l      #BonusEvents1, MEM_next_bonus_stage
    move.l      #LVL_Queue_ForestNight, MEM_next_level
    move.l      #DayForestThemeBegin, MEM_level_bgm_begin
    move.l      #DayForestThemeEnd-1, MEM_level_bgm_end
    Goto_Level  TestRoom_level, TESTROOM_tiles, #10368, Palettes_TESTROOM
    jmp         next_level_queued

LVL_Queue_ForestNight:
    move.l      #0, MEM_level_post_init_handler
    move.l      #0, MEM_next_bonus_stage
    move.l      #LVL_Queue_ForestBoss, MEM_next_level
    move.l      #DarkForestThemeBegin, MEM_level_bgm_begin
    move.l      #DarkForestThemeEnd-1, MEM_level_bgm_end
    Goto_Level  ForestNight_Level, TESTROOM_tiles, #10368, ForestNight_Palettes
    jmp         next_level_queued

LVL_Queue_ForestBoss:
    move.l      #LVL_ForestBoss_PostInit, MEM_level_post_init_handler
    move.l      #0, MEM_next_bonus_stage
    move.l      #0, MEM_next_level
    move.l      #DarkForestThemeBegin, MEM_level_bgm_begin
    move.l      #DarkForestThemeEnd-1, MEM_level_bgm_end


    ; Using the first 263 tiles from the forest set (for ground and bg)
    ; and then add the 333 tiles necessary for  the skeleton boss
    Goto_Level  ForestBossLevel, TESTROOM_tiles, #4208, ForestBoss_Palettes

    jmp         next_level_queued

LVL_ForestBoss_PostInit:
    ; add the 333 tiles necessary for  the skeleton boss
    move.l      #333<<4, d1
    move.l      #ForestBoss_Tiles, d2
    move.l      #16000, d3
    jsr         TriggerDMADumpToVRAM
    jmp         lvl_post_init_return