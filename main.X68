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
    ; These are system constants that will be the same or similar for other ROMS
    include './constants/constants_segagenesis.X68'
    include './constants/constants_ascii.X68'
    include './constants/constants_gamestates.X68'
    
*==============================================================
* Memory Map for this ROM
*==============================================================
mem_start               EQU $FFFF0000
frame_state             EQU $FFFF0000       ;WORD
frame_counter           EQU $FFFF0002       ;WORD

MEM_buttons_held        EQU $FFFF0004       ;BYTE
MEM_buttons_pressed     EQU $FFFF0005       ;BYTE

MEM_camera_pos          EQU $FFFF0006       ;WORD
MEM_camera_y            EQU $FFFF0006       ;WORD
MEM_camera_z            EQU $FFFF0008       ;WORD

MEM_player_pos_x        EQU $FFFF0006       ;WORD
MEM_player_pos_y        EQU $FFFF0008       ;WORD
MEM_player_direction    EQU $FFFF000A       ;WORD

MEM_gamestate           EQU $FFFF000C       ;BYTE

MEM_fade                EQU $FFFF000D       ;WORD

*==================================
* Flags
*==================================
vblank_on_flag          EQU $00000001

*==================================
* Game Constants
*==================================
player_speed            EQU $02

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
    include './macros/macros_input.X68'
    include './macros/macros_vdp.X68'
    include './macros/macros_scrolling.X68'
    include './macros/macros_gamestates.X68'
    include './macros/macros_level.X68'

Main:
    include './init/init_validatetmss.X68'
    
*================================================
* Coprocessor and Inputs Setup
*================================================
    include './init/init_vdp.X68' 
    include './init/init_inputs.X68' 
    include './init/init_clearmem.X68'

    ; Start the game off at the introduction
    Goto_IntroClouds

MainLoop:
    bsr.w   WaitVBlank
    ; a6 holds the main loop handler
    jmp (a6)

*---------------------------------
* Game States and frame handlers
*---------------------------------
    include './gamestates/gamestate_introclouds.X68'
    include './gamestates/gamestate_title.X68'
    include './gamestates/gamestate_level.X68'

*-----------------------------
* Utility Subroutines
*-----------------------------
    include './subroutines/sub_waitvblank.X68'
    include './subroutines/sub_readinput.X68'
    
*-----------------------------
* Traps
*-----------------------------
HBlank:
    rte

VBlank:
	bset	#vblank_on_flag, (frame_state)
	addq    #1, (frame_counter)
    bsr.s   ReadInput
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
* Art Assets Subroutines
*===============================
    include './subroutines/sub_palettes.X68'
    include './subroutines/sub_loadtiles.X68'
    include './subroutines/sub_stamps.X68'
    include './subroutines/sub_levels.X68'

*===============================
* Art/Sound/Text Assets
* ===============================
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

    include './assets/palettes/palettes_titlescreen.X68'
    include './assets/tiles/tiles_titlescreen.X68'

    ; Genesis does - mario!
    include './assets/levels/mario11/tiles.X68'
    include './assets/levels/mario11/palette.X68'
    include './assets/levels/mario11/level.X68'

RomEnd:






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
