*-----------------------------------------------------------
* Title      :  "Violent Dragon Rabbit"
* Written by :  Jason Ioffe
* Date       :
* Description:  You are a rabbit with the soul of a dragon.
*               Defeat evil for great justice!
*-----------------------------------------------------------
RomStart:
*======================
* Import Constants
*======================
    include './constants/constants_segagenesis.X68'
    include './constants/constants_gfx.X68'
    include './constants/constants_sfx.X68'
    include './constants/constants_ascii.X68'
    include './constants/constants_gamestates.X68'
    include './constants/constants_player.X68'
    
*==============================================================
* Memory Map(s) for this ROM
*==============================================================
    include './memorymaps/mem_main.X68'


*==================================
* Flags
*==================================
vblank_on_flag                  EQU $0001
score_changed                   EQU $0002
game_paused                     EQU $0003

*-----------------------------------------------------------
* CPU VECTORS
* These give the runtime some hints and must be first (address 0)
*-----------------------------------------------------------
    include './init/init_cpuvectors_common.X68'
*----------------------------------------------
* Sega Genesis ROM Metadata
* (Reference: https://en.wikibooks.org/wiki/Genesis_Programming)
* ---------------------------------------------
	dc.b	'SEGA GENESIS    '	; console name
	dc.b	'(C)JIOFF'	        ; copyright
 	dc.b	'2019.AUG'			; date
	dc.b	'VIOLENT DRAGON RABBIT                           ' ; cart name
	dc.b	'VIOLENT DRAGON RABBIT                           ' ; cart name (alt)
	dc.b	'GM 12345678-01'	; program type / serial number / version
	dc.w	$0000				; ROM checksum
	dc.b	'J               '	; I/O device support (unused)
	dc.l	$00000000			; address of ROM start
	dc.l	RomEnd				; address of ROM end
    dc.l    ram_start
    dc.l    ram_end
    dc.b    '    '
    dc.b    '    '
    dc.b    '    '
    dc.b    '            '                           
    dc.b    '                                        '
    dc.b    'JUE             '
    
*================================================
* Macros
*================================================
    include './macros/macros_math.X68'
    include './macros/macros_input.X68'
    include './macros/macros_vdp.X68'
    include './macros/macros_scrolling.X68'
    include './macros/macros_gamestates.X68'
    include './macros/macros_level.X68'
    include './macros/macros_camera.X68'
    include './macros/macros_sprites.X68'
    include './macros/macros_effects.X68'
    include './macros/macros_player.X68'
    include './macros/macros_enemies.X68'
    include './macros/macros_score.X68'
    include './macros/macros_z80.X68'

Main:
    include './init/init_validatetmss.X68'
    
*================================================
* Coprocessor and Inputs Setup
*================================================
    include './init/init_SFX.X68' 
    include './init/init_vdp.X68' 
    include './init/init_inputs.X68' 
    include './init/init_clearmem.X68'

    ; Begin the game at the licensing screen
    lea     NoOpTrap, a6
    Goto_Licensing

MainLoop:
    WaitVBlank
    ; a6 holds the main loop handler
    jmp (a6)

*---------------------------------
* Game States and frame handlers
*---------------------------------
    include './gamestates/gamestate_licensing.X68'
    include './gamestates/gamestate_introclouds.X68'
    include './gamestates/gamestate_title.X68'
    include './gamestates/gamestate_level.X68'
    include './gamestates/gamestate_bonus_clouds.X68'
    include './gamestates/gamestate_end.X68'

*-----------------------------
* Utility Subroutines
*-----------------------------
    include './subroutines/sub_readinput.X68'
    
*-----------------------------
* Traps
*-----------------------------
HBlank:
    movea.l MEM_hblank_handler, a0
    jmp (a0)

VBlank:
    movem.l d0-d7/a0-a5, -(SP)
    bsr.s   ReadInput
    bset	#vblank_on_flag, frame_state

    btst    #game_paused, frame_state
    bne.s   vblank_paused   
	    add.w   #1, (frame_counter)
    vblank_paused:

    *------------------------------------------------------
    * DMA - 68K to VDP
    *------------------------------------------------------
    ; Best to do DMA on VBlank - VDP has the most bandwidth
    moveq   #0, d0
    move.b  MEM_vblank_mode, d0
    btst    #vsync_dump_sprites, d0
    beq.s   skip_sprites
        DMADumpSpriteBuffer                     ; copy all the updated sprites to VRAM
    skip_sprites:

    btst    #vsync_dump_player, d0
    beq.s   skip_player_gfx
        * Dump player tile data to VRAM
        move.l  MEM_player_previous_frame, a0
        moveq   #0, d3
        move.w  MEM_player_tiles_start, d3                    ; address of player tile data in VRAM
        bsr.w   PushEmbeddedSpriteFrame
    skip_player_gfx:

    btst    #vsync_dump_score, d0
    beq.s   skip_score
        bsr.w   UpdateScoreGfxIfDirty
    skip_score:

    movem.l (SP)+, d0-d7/a0-a5
	rte
    
HandleException:
    stop    #$2700
    rte
    
NotHandled:
    rte

*===============================
* VDP Registers Array
*=============================== 
    include './init/init_vdp_attributes_intro.X68'
    
*===============================
* Subroutines
*===============================
    include './subroutines/sub_dma.X68'
    include './subroutines/sub_ram.X68'
    include './subroutines/sub_palettes.X68'
    include './subroutines/sub_loadtiles.X68'
    include './subroutines/sub_stamps.X68'
    include './subroutines/sub_levels.X68'
    include './subroutines/sub_sprites.X68'
    include './subroutines/sub_collision.X68'
    include './subroutines/sub_effects.X68'
    include './subroutines/sub_gui.X68'
    include './subroutines/sub_text.X68'

*===============================
* Art/Sound/Text Assets
* ===============================
    ; Some system variables
    palette_empty:
    dc.w    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0

    ; There is room for 8 digits in the score but
    ; keep it to 6 steps for the loops.. add trailing 0s
    SCORE_number:
    number_10000000: 
    number_100000:      dc.l    100000
    number_10000:       dc.l    10000
    number_1000:        dc.l    1000
    number_100:         dc.l    100
    number_10:          dc.l    10
    number_1:           dc.l    1

    include './assets/palettes/palettes_system.X68'

    include './assets/player/baolongtu_sprite.X68'
    include './assets/cutscenes/intro_storm/palette.X68'
    include './assets/cutscenes/intro_storm/stamps.X68'
    include './assets/cutscenes/intro_storm/tiles_clouds.X68'
    include './assets/cutscenes/intro_storm/tiles_lightningA.X68'
    include './assets/cutscenes/intro_storm/intro_lightningA.X68'
    include './assets/cutscenes/intro_storm/tiles_fight.X68'
    include './assets/cutscenes/intro_storm/intro_fightA.X68'
    include './assets/cutscenes/intro_storm/intro_fightB.X68'
    include './assets/cutscenes/intro_storm/intro_slash.X68'
    include './assets/cutscenes/intro_storm/intro_slash_tiles.X68'
    include './assets/cutscenes/intro_storm/pattern_trees.X68'

    include './assets/title-screen/palette.X68'
    include './assets/title-screen/tiles.X68'
    include './assets/title-screen/title-rabbit.X68'
    include './assets/title-screen/title-logo.X68'
    include './assets/title-screen/nose-twitch.X68'
    include './assets/title-screen/press-start.X68'

    include './assets/levels/core-tiles.X68'
    include './assets/levels/core-sprites.X68'
    include './assets/levels/numbers-tiles.X68'

    include './assets/fonts/font_a.X68'
    
    ; FOR TEST ROOM
    include './assets/levels/testroom/tiles.X68'
    include './assets/levels/testroom/palette.X68'
    include './assets/levels/testroom/bg.X68'
    include './assets/levels/testroom/level.X68'
    include './assets/levels/testroom/enemies.X68'

    ; BONUS!!!!
    include './assets/bonus-stages/clouds/include.X68'

    include './assets/end-screen/include.X68'

*=====================================
* Items / Enemies / Thingamabobs
*=====================================
    include './assets/items/item_table.X68'
    include './assets/effects/effects_table.X68'

*========================================
* Sound drivers and other assets for Z80
*========================================
    include './z80/include.X68'

    NoOpTrap:
        jmp     MainLoop
*=====================================================
* It don't mean a thing if you ain't got the strings
* Included last in case of any alignment issues...
*=====================================================
    include './assets/strings/strings_sys.X68'
RomEnd:
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
