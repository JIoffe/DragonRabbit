bloodspurt4:
   dc.w $0F00
   dc.w $0030

bloodspurt3:
   dc.w $0F00
   dc.w $0020

bloodspurt2:
   dc.w $0F00
   dc.w $0010

bloodspurt1:
   dc.w $0F00
   dc.w $0000

gem:
   dc.w $0500
   dc.w $0040

sparkle1:
   dc.w $0500
   dc.w $0044

sparkle2:
   dc.w $0500
   dc.w $0048

score_label:
   dc.w $0C00
   dc.w $004C

* Compression: NONE
* Embedded: TRUE
* Tiles to Allocate: 32
GoalFlag:
    GoalFlag_Unrolled:
    dc.w $0000           ; frame count
    dc.l GoalFlag_Unrolled0
    GoalFlag_Unrolled0:
    dc.w $0200           ; (total byte size of tiles / 2)
        dc.l $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $000000AA, $0000AA00
        dc.l $00AA3333, $00453333, $00453FFF, $09495FFF, $04959111, $0445511F, $04455111, $0045311F
        dc.l $00003111, $00003111, $00003111, $00003111, $00003111, $00003111, $00003111, $00003111
        dc.l $00003111, $00003111, $00003111, $00003111, $00003111, $00003111, $00003111, $00003111
        dc.l $00000003, $00000003, $0000000A, $000000AA, $0000AA03, $0AAA0003, $A0000003, $00000003
        dc.l $33333333, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $11111111, $1F111111, $F1111111, $1AAA1111
        dc.l $1A99A111, $1A999A11, $11A999A1, $111A999A, $1111A999, $11111A79, $11111A77, $1111A999
        dc.l $1111A999, $1111A999, $11111A99, $111111AA, $11F11111, $111F1111, $11F1A911, $111FA999
        dc.l $30000000, $30000000, $A0000000, $AA000000, $30AA0000, $3000AAA0, $3000000A, $30000000
        dc.l $33333333, $FFF33333, $FFFFFFF3, $FFFFFFFF, $1111FFFF, $11111111, $11111111, $11111AA1
        dc.l $1111A9A1, $111A99A1, $11A999A1, $AA999A11, $9999A111, $997A1111, $977A1111, $9999A111
        dc.l $A999A111, $9999A111, $999A1111, $AAA11111, $11111111, $11111111, $11111111, $99991111
        dc.l $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $AA000000, $00AA0000
        dc.l $3333AA00, $33334500, $33334500, $F3394950, $FF349590, $FF344550, $FFF44550, $FFF34500
        dc.l $FFF30000, $1FF30000, $1FF30000, $1FF30000, $1FF30000, $1FF30000, $11F30000, $11130000
        dc.l $11130000, $11130000, $11130000, $11130000, $11130000, $11130000, $11130000, $11130000
        dc.l $00003111, $00003111, $00003111, $00003111, $0000311A, $00003111, $00003111, $00003111
        dc.l $00003F11, $00003FF1, $00003FFF, $00003FFF, $00003FFF, $00003FFF, $00003FFA, $000033FF
        dc.l $000033FF, $00EE3333, $0EEE3333, $00EE3333, $00000000, $00000000, $00000000, $00000000
        dc.l $111A91F1, $11A9111F, $1A911111, $A9999999, $9A91111A, $1A91111A, $1A91111A, $1A999999
        dc.l $111111A9, $111111A9, $11111A91, $1111A911, $F11A9111, $FA991111, $99F11111, $FFFFFFFF
        dc.l $FFFFFFFF, $3333FFFF, $3333333F, $33333333, $00000003, $00000003, $00000003, $00000003
        dc.l $11A91111, $FA911111, $A9111111, $99999991, $91111A91, $91111A91, $91111A91, $99999991
        dc.l $A91111F1, $A9A91F1F, $A91A91F1, $A911A911, $A911111A, $A911111A, $1A999999, $FFFFFFFF
        dc.l $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $33333333, $30000000, $30000000, $30000000, $30000000
        dc.l $11130000, $11130000, $11130000, $11130000, $11130000, $11130000, $11130000, $F1130000
        dc.l $F1130000, $11130000, $11130000, $11130000, $91130000, $91130000, $91130000, $FFF30000
        dc.l $FFF30000, $FFF3EE00, $FFF3EEE0, $3333EE00, $00000000, $00000000, $00000000, $00000000
        dc.l $00033000, $00033000, $00033000, $00033000, $00033000, $00033000, $00033000, $00033000
        dc.l $00000000, $00000000, $000000E3, $0000EE1E, $000E31FE, $000E3FEE, $00EEEEEE, $00EEEEEE
        dc.l $00033000, $00033000, $EEEEEEEE, $EEEEEEEE, $EEEEEEEE, $EEEEEEEE, $EEEEEEEE, $EEEEEEEE
        dc.l $00000000, $00000000, $EE000000, $EEEE0000, $EEEEE000, $EEEEE000, $EEEEEE00, $EEEEEE00
        dc.w $0003
        dc.w $0000           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $0000           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0020           ; Offset Vertical
        dc.w $0E00     ; sprite Size
        dc.w $0010           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0038           ; Offset Vertical
        dc.w $0000     ; sprite Size
        dc.w $001C           ; sprite tile ID
        dc.w $0C0C           ; Offset Horizontal
        dc.w $0040           ; Offset Vertical
        dc.w $0800     ; sprite Size
        dc.w $001D           ; sprite tile ID
        dc.w $0404           ; Offset Horizontal



; Level Effects
ChickenFeathers:
   dc.w $0500
   dc.w $019E

NutProjectile:
   dc.w $0500
   dc.w $0285
