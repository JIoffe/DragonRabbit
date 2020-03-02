BOSS_ForestSkeleton_width                 EQU     55
BOSS_ForestSkeleton_height                EQU     96
BOSS_ForestSkeleton_bb_offset             EQU     (BOSS_ForestSkeleton_height<<16)|BOSS_ForestSkeleton_width

BOSS_ForestSkeleton_lance_offset          EQU     (58<<16)|51
BOSS_FSkeleton_lance_bb_offset            EQU     (15<<16)|70

BOSS_ForestSkeleton_speed                 EQU     $01
BOSS_ForestSkeleton_Points                EQU     100 

BOSS_ForestSkeletonrecoil_frames          EQU     4

BOSS_ForestSkeleton_Update:
    movea.l a4, a3          ; save a reference to this address to update later
    move.b  (a4)+, d6
    move.l  (a4)+, d1

    tst.b   d6
    beq.w   BOSS_ForestSkeleton_Done       ; dead as a doorknob

    ; This boss's logic executes even when out of view. THERE IS NO ESCAPE!
    ; For his state... he has 36 HP
    ; His actions are synced to time so we just use the least significant
    ; portion of his state for HP. For more complex bosses, could make a
    ; dedicated supplementary section in RAM
    HurtPlayerIfTouching    #BOSS_ForestSkeleton_bb_offset

    ; Adjust hitbox a little lower so the player can't cheese the fight
    move.l  d1, -(SP)
    add.l   #$00100000, d1
    GetDamageReceived   #BOSS_ForestSkeleton_bb_offset
    move.l  (SP)+, d1
    moveq   #0, d7
    move.b  mem_boss_state, d7
    lsr.b   #3, d7

    tst.b   d3
    beq.s   ForestBoss_Dmg_Taken_Done
    move.b  #BOSS_ForestSkeletonrecoil_frames, d7
    sub.b   d3, d6

    ; Winner, winner, chicken dinner
    tst.b   d6
    bne.s   ForestBoss_Dmg_Taken_Done
    ; make some blood - would be nice to make bones fly out sometime
    addi.l  #$00100020, d1
    move.l  #3, d0
    forestboss_blood_loop:
        AddBloodSpurt
        addi.l  #$00100000, d1
        dbra    d0, forestboss_blood_loop
    move.w  #0, frame_counter
    jsr     FanfareSFX
    lea     LevelClearedLoop, a6
    move.b  d6, (a3)
    jmp (a5)

    ForestBoss_Dmg_Taken_Done:

    ; Flash if damage was taken recently
    tst.b   d7
    beq.s   ForestBoss_FlashOff
        lea     ForestBoss_Palettes_Flash, a0
        subq    #1, d7
        move.b  mem_boss_state, d3
        andi.b  #7, d3
        lsl.b   #3, d7
        add.b   d3, d7
        move.b  d7, mem_boss_state
        bra.s   ForestBoss_FlashDone
    ForestBoss_FlashOff:
        lea     ForestBoss_Palettes_Boss, a0
    ForestBoss_FlashDone:
    
    moveq   #0, d0
    move.b  #15, d0
    move.l  d1, -(SP)
    moveq   #3, d1
    jsr   LoadPaletteOffset             ; change palette for the boss to what's appropriate
    move.l  (SP)+, d1

    
    ; Attack approximately every 3 seconds
    ; 3 Sec - Stop and get ready
    ; 1 sec - ATtack
    ; 1 sec - recover
    ; most significant bits:
    ; 00 - Walking
    ; 01 - Getting ready
    ; 10 - Attacking

    move.w  frame_counter, d3
    
    boss_skeleton_check_attacking:
        btst    #7, d6
        beq.s   boss_skeleton_check_ready
        ;Attack player with lance
        move.l  d1, -(SP)
        addi.l  #BOSS_ForestSkeleton_lance_offset, d1
        btst    #sprite_flip_h, mem_boss_state
        beq.s   boss_skel_attack_flipped
            ; adjust for left-facing lance
            sub.w   #72+player_width, d1
        boss_skel_attack_flipped:
        HurtPlayerIfTouching    #BOSS_FSkeleton_lance_bb_offset
        move.l  (SP)+, d1

        lea     SkeletonBoss_sprite_Attack1, a0

        move.w  frame_counter, d3
        andi.w  #63, d3
        bne.w   boss_skeleton_logic_done
        bclr    #7, d6
        move.b  d6, (a3)
        bra.w   boss_skeleton_logic_done

    boss_skeleton_check_ready:
        btst    #6, d6
        beq.s   boss_skeleton_walking
        lea     SkeletonBoss_sprite_Attack0, a0
        andi.w  #63, d3
        bne.w   boss_skeleton_logic_done
        bclr    #6, d6
        bset    #7, d6
        move.b  d6, (a3)
        bra.w   boss_skeleton_logic_done

    boss_skeleton_walking:
        andi.w  #255, d3
        bne.s   boss_skeleton_not_ready
            bset    #6, d6
        boss_skeleton_not_ready:
        move.b  d6, (a3)

        move.w  frame_counter, d3
        ToggleFrames    #32, SkeletonBoss_sprite_Walking0, SkeletonBoss_sprite_Walking1, d3

        addq    #1, a3

        move.b  MEM_player_hp, d3               ; Don't chase dead rabbits
        beq.s   boss_skeleton_logic_done

        move.w (MEM_player_pos_x), d3           ; always face the player
        sub.w   d1, d3
        bcc.s   boss_skeleton_flip_off
        boss_skeleton_flip_on:
            bset    #sprite_flip_h, mem_boss_state
            subq    #BOSS_ForestSkeleton_speed, d1
            bra.s   boss_skeleton_flipped
        boss_skeleton_flip_off:
            sub.w   #BOSS_ForestSkeleton_width, d3
            bmi.s   boss_skeleton_flipped
            bclr    #sprite_flip_h, mem_boss_state
            addq    #BOSS_ForestSkeleton_speed, d1
        boss_skeleton_flipped:
        move.l  d1, (a3)

    boss_skeleton_logic_done:

    ; But render is only in view
    CancelOutOfView     BOSS_ForestSkeleton_Done, d2, d1, #BOSS_ForestSkeleton_bb_offset, d3

    ; Select animation based on state
    move.b  mem_boss_state, d6
    andi.b  #7, d6
    moveq   #0, d7
    move.w  #cram_palette_3_bits|499, d7        ; Mr. Bones uses the last palette
    jsr     DrawSpriteFrame

    BOSS_ForestSkeleton_Done:
    jmp (a5)