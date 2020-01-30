********************************************
* Uploads the primary gameplay (level) SFX 
* program to the Z80's memory
********************************************
WritetoZ80:
    bsr.w   PrepareZ80MemWrite
    sub.l   a0, d0
    bsr.w   MemCpy
    bsr.w   CommiteZ80MemWrite
    rts
UploadCoreSoundDriver:
    movem.l d0/a0-a1, -(SP)
    lea     CoreSFXDriverBegin, a0
    lea.l   (z80_ram).l, a1
    move.l  #CoreSFXDriverEnd-1, d0
    bsr.s   WritetoZ80
    movem.l (SP)+, d0/a0-a1
    rts

UploadGameplaySFXProgram:
    movem.l d0/a0-a1, -(SP)
    lea     LevelSFXBegin, a0
    lea.l   (z80_ram+sfx_driver_size).l, a1
    move.l  #LevelSFXEnd-1, d0
    bsr.s   WritetoZ80
    movem.l (SP)+, d0/a0-a1
    rts

UploadTitleSFXProgram:
    movem.l d0/a0-a1, -(SP)
    lea     TitleSFXBegin, a0
    lea.l   (z80_ram+sfx_driver_size).l, a1
    move.l  #TitleSFXEnd-1, d0
    bsr.s   WritetoZ80
    movem.l (SP)+, d0/a0-a1
    rts

PrepareZ80MemWrite:
    StopZ80
    ResetZ80
    WaitZ80
    rts

CommiteZ80MemWrite:
    ReloadZ80
    Z80BusSync
    ReleaseZ80
    Z80BusSync
    ResetZ80
    Z80BusSync
    rts
***************************************
* Sets the address of the desired SFX
* to the Z80's callback
***************************************
* d0 - desired address
SetSFX:
    move.w	#interrupts_disable, sr
    StopZ80
    WaitZ80
    move.b  d0, z80_sfx_ptr
    lsr.w   #8, d0
    move.b  d0, (z80_sfx_ptr+1)
    ReleaseZ80
    Z80BusSync
    move.w	#interrupts_enable, sr
    rts

PlayerDeathJingle:
    move.w  d0, -(SP)
    move.w  #sfx_playerdead, d0
    jsr     SetSFX
    move.w  (SP)+, d0
    rts

PlayerHurtJingle:
    move.w  d0, -(SP)
    move.w  #sfx_playerhurt, d0
    jsr     SetSFX
    move.w  (SP)+, d0
    rts

FanfareSFX:
    move.w  d0, -(SP)
    move.w  #sfx_fanfare, d0
    jsr     SetSFX
    move.w  (SP)+, d0
    rts