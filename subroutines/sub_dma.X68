**************************************
* Copies from M68K to VRAM
* d1.w = Length in bytes / 2
* d2.l = Src Address (RAM/ROM)
* d3.l = Dest Address (VRAM)
* a0,d1-d4 - trashed
TriggerDMADumpToVRAM:
    lea.l   vdp_control, a0

    * \1 - register with length in bytes
    * \2 - register with Src Address
    * \3 - trash register
    * \4 - address of VDP control port
    DMA68KSetSrc    d1, d2, d4, (a0)

    ; DMA triggered when destination address set
    move.l  #$40000080, d1
    moveq   #0, d4
    move.w  d3, d4
    andi.w  #$3FFF, d4
    swap    d4
    add.l   d4, d1

    andi.w  #$C000, d3
    swap    d3
    rol.l   #2, d3
    add.l   d3, d1


    move.l  d1, (a0)       ; destination address + start DMA
    rts