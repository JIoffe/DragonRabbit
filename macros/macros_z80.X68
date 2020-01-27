StopZ80 	macro
    move.w	#$100, (z80_bus_control).l
    endm

ReleaseZ80  macro
    move.w	#0, (z80_bus_control).l
    endm

ResetZ80    macro
    move.w  #$100, (z80_reset).l
    endm

ReloadZ80   macro
    move.w	#0, (z80_reset).l
    endm

WaitZ80	    macro
wait\@
    btst    #0, (z80_bus_control).l
    bne.s   wait\@
    endm

SilencePSG68k   macro
    ;Mute all PSG channels
    move.b  #%10011111, psg_tone_port
    move.b  #%10111111, psg_tone_port
    move.b  #%11011111, psg_tone_port
    move.b  #%11111111, psg_tone_port
    endm

Z80BusSync  macro
    nop
    nop
    nop
    endm

