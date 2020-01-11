*===============================================================================
* Macros related to VDP and video memory
*===============================================================================
*------------------------------------
* Sends register init commands to VDP
* - \1 = Address of register to load
*------------------------------------
SetVDPRegisters macro
    lea     \1, a0
    move.l  #vdp_register_count, d0     
loop\@
        move.w  \4+, vdp_control
        dbra    d0, loop\@
    endm
    
*---------------------------------------
* Clears all VRAM
*---------------------------------------
ClearVram macro
    lea.l   vdp_control, a0
    move.l  #$40000080, (a0)
    lea.l   vdp_data, a0
    
    moveq   #0, d0
    move.w  #$7CFF, d0
loop\@
    move.w  #0, (a0)
    dbra    d0, loop\@
    endm

*---------------------------------------------------
* Prepares 68k -> VDP DMA with constant values
*---------------------------------------------------
* \1 - register with length in bytes
* \2 - register with Src Address
* \3 - trash register
* \4 - address of VDP control port
DMA68KSetSrc    macro
    move.w  d1, d4
    andi.w  #$00FF, d1
    addi.w  #$9300, d1
    move.w	d1, (a0)            ; Low byte of length

    andi.w  #$FF00, d4
    lsr.w   #8, d4
    addi.w  #$9400, d4
	move.w	d4, (a0)            ; High byte of length

    lsr.l   #1, d2              ; Divide address by 2
    moveq   #0, d4
    move.b  d2, d4
    addi.w  #$9500, d4
    move.w  d4, (a0)            ; low byte of src address

    move.w  d2, d4
    andi.w  #$FF00, d4
    lsr.w   #8, d4
    addi.w  #$9600, d4      
    move.w  d4, (a0)            ; middle byte of src address

    swap    d2
    andi.w  #$7F, d2
    addi.w  #$9700, d2      
    move.w  d2, (a0)            ; high byte of src address
    endm
*---------------------------------------------------
* Triggers 68k -> VRAM DMA with constant values
*---------------------------------------------------
* \1 - length in bytes
* \2 - Src Address
* \3 - Destination Address
DMA68KtoVRAM    macro
    move.w  #\1/2, d1
    move.l  #\2, d2
    move.l  #\3, d3
    jsr     TriggerDMADumpToVRAM
    endm

*---------------------------------------------------
* Triggers 68k -> CRAM DMA with constant values
*---------------------------------------------------
* \1 - length in bytes
* \2 - Src Address
* \3 - Destination Address
DMA68KtoCRAM    macro
    DMA68KSetSrc \1, \2
    ; Set destination and trigger DMA
	move.l  #$C0000080+(\3<<16), vdp_control
    endm

*------------------------------------
* Blocks M68K until DMA is complete
*------------------------------------
WaitDMA macro
wait\@
    move.w  (vdp_control), d0
    btst    #1, d0
    bne.s   wait\@
    endm

*------------------------------------
* Sets BG in CRAM (pal 0, col 0)
* - \1 = COLOR to set
*------------------------------------
SetBG macro
    move.l  #vdp_cram_write, vdp_control
    move.w  \1, vdp_data
    endm


*---------------------------------------
* Sends a VRAM Tile Command
* - \1 register with offset
* - \2 temp register
*---------------------------------------
WriteVramTilesByBytes macro
    ; VRAM commands are a little funky
    ; the last two bits of the address have to be the first 2 bits in the command
	move.w	\1, \2
	andi.w	#$C000, \2		; mask out the last two bits and move them to the front
	rol.w	#2, \2

	andi.w	#$3FFF, \1
	swap	\1
	addi.l	#vdp_vram_tiles, \1
	or.l	\2, \1
    move.l  \1, vdp_control
    endm

*---------------------------------------
* Sends a VRAM Tile Command
* - \1 register with offset
* - \2 temp register
*---------------------------------------
WriteVramTilesByTiles macro
    lsl.w	#5, \1          ; multiply by 32 bytes to get the offset
    WriteVramTilesByBytes \1, \2
    endm

*---------------------------------
* - Enables HBlank, H/V Counter, and Registers a callback
* - \1 address of HBlank handler
* - \2 scanlines between H Interrupts
EnableHBlank    macro
    move.l  \1, MEM_hblank_handler
    move.w  #$8014, vdp_control
    move.w  #$8A00+\2, vdp_control
    endm

DisableHBlank   macro
    move.w  #$8004, vdp_control     ; explicitly disable H Int
    move.w  #$8AFF, vdp_control     ; set H Int to every 255 lines ( never happens )
    endm