write './bin/title-screen-sfx.bin'	;WinAPE build target
read	'./Plugin-constants.asm'

sfx_title_theme:
	startbgm_loop	song+sfx_coredriver_size
song:
incbin '../assets/bgm/baolongtu.vgm'