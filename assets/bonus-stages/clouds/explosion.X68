* Compression: NONE
* Embedded: FALSE
* Tiles to Allocate: 24
Explosion:
    Explosion_Explode:
    dc.w $0003           ; frame count
    dc.l Explosion_Explode3
    dc.l Explosion_Explode2
    dc.l Explosion_Explode1
    dc.l Explosion_Explode0
    Explosion_Explode0:
        dc.w $0001
        dc.w $00FE           ; Offset Vertical
        dc.w $0B00     ; sprite Size
        dc.w $01F4           ; sprite tile ID
        dc.w $000C           ; Offset Horizontal
        dc.w $0007           ; Offset Vertical
        dc.w $0600     ; sprite Size
        dc.w $0200           ; sprite tile ID
        dc.w $18FC           ; Offset Horizontal
    Explosion_Explode1:
        dc.w $0001
        dc.w $00FF           ; Offset Vertical
        dc.w $0B00     ; sprite Size
        dc.w $0206           ; sprite tile ID
        dc.w $18F7           ; Offset Horizontal
        dc.w $00FC           ; Offset Vertical
        dc.w $0B00     ; sprite Size
        dc.w $0212           ; sprite tile ID
        dc.w $000F           ; Offset Horizontal
    Explosion_Explode2:
        dc.w $0001
        dc.w $00FA           ; Offset Vertical
        dc.w $0700     ; sprite Size
        dc.w $021E           ; sprite tile ID
        dc.w $0013           ; Offset Horizontal
        dc.w $00FE           ; Offset Vertical
        dc.w $0B00     ; sprite Size
        dc.w $0226           ; sprite tile ID
        dc.w $10FB           ; Offset Horizontal
    Explosion_Explode3:
        dc.w $0003
        dc.w $00FA           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $0232           ; sprite tile ID
        dc.w $0AF7           ; Offset Horizontal
        dc.w $00F8           ; Offset Vertical
        dc.w $0000     ; sprite Size
        dc.w $0242           ; sprite tile ID
        dc.w $0118           ; Offset Horizontal
        dc.w $0008           ; Offset Vertical
        dc.w $0000     ; sprite Size
        dc.w $0243           ; sprite tile ID
        dc.w $0019           ; Offset Horizontal
        dc.w $0015           ; Offset Vertical
        dc.w $0000     ; sprite Size
        dc.w $0244           ; sprite tile ID
        dc.w $0217           ; Offset Horizontal
