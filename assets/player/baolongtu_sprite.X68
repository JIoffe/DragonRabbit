* Compression: NONE
* Embedded: TRUE
BaoLongTu_sprite:
    BaoLongTu_sprite_Idle:
    dc.w $0000           ; frame count
    dc.l BaoLongTu_sprite_Idle0
    BaoLongTu_sprite_Idle0:
    dc.w $001F           ; (total tiles in frame * 8) - 1
        dc.l $11000000, $1F100000, $1FF10000, $1FFF1100, $1FFFFF10, $1FFFFFE1, $1FFFEFEE, $1FFEEEEE
        dc.l $1EFEEEED, $1EEEEDDD, $1EEEDDDD, $1E1111CC, $1100001C, $00000001, $00000000, $00000000
        dc.l $00000000, $00000000, $00000000, $00000000, $00000000, $10000000, $E1000000, $ED110000
        dc.l $DDDC1000, $11111100, $10000000, $C1000000, $CB100000, $BBB10000, $1BB10000, $01100000
        dc.w $0000
        dc.w $00           ; Offset Vertical
        dc.w $0500     ; sprite Size
        dc.w $0000           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
