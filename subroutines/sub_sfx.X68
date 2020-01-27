********************************************
* Uploads the primary gameplay (level) SFX 
* program to the Z80's memory
********************************************
UploadPrimarySFXProgram:
    movem.l d0/a0-a1, -(SP)
    lea     LevelSFXDriverBegin, a0
    move.l  #LevelSFXDriverEnd-1, d0
    bsr.s   UpdateZ80Program
    movem.l (SP)+, d0/a0-a1
    rts
******************************************
* Copies the driver from a0 to shared RAM
* a0 - driver start
* a1 - Trashed
* d0 - driver end/Trashed
UpdateZ80Program:
    StopZ80
    ResetZ80
    WaitZ80

    lea.l   (z80_ram).l, a1
    sub.l   a0, d0
    sound_driver_loop:
        move.b  (a0)+, (a1)+
        dbra    d0, sound_driver_loop

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
    StopZ80
    WaitZ80
    move.b  d0, z80_sfx_ptr
    lsr.w   #8, d0
    move.b  d0, (z80_sfx_ptr+1)
    ReleaseZ80
    Z80BusSync
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