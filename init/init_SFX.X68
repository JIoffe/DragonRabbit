InitSFX:
    StopZ80
    ResetZ80
    
    ;Mute all PSG channels
    move.b  #%10011111, psg_tone_port
    move.b  #%10111111, psg_tone_port
    move.b  #%11011111, psg_tone_port
    move.b  #%11111111, psg_tone_port