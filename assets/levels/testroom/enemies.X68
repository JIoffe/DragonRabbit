* Compression: NONE
* Embedded: FALSE
* Tiles to Allocate: 22
Moguren:
    Moguren_Walking:
    dc.w $0001           ; frame count
    dc.l Moguren_Walking0
    dc.l Moguren_Walking1
    Moguren_Walking0:
        dc.w $0001
        dc.w $00           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $0108           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $20           ; Offset Vertical
        dc.w $0800     ; sprite Size
        dc.w $0118           ; sprite tile ID
        dc.w $0503           ; Offset Horizontal
    Moguren_Walking1:
        dc.w $0001
        dc.w $00           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $011B           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $20           ; Offset Vertical
        dc.w $0400     ; sprite Size
        dc.w $012B           ; sprite tile ID
        dc.w $0907           ; Offset Horizontal
    Moguren_Hurt:
    dc.w $0000           ; frame count
    dc.l Moguren_Hurt0
    Moguren_Hurt0:
        dc.w $0001
        dc.w $08           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $012D           ; sprite tile ID
        dc.w $1000           ; Offset Horizontal
        dc.w $08           ; Offset Vertical
        dc.w $0600     ; sprite Size
        dc.w $013D           ; sprite tile ID
        dc.w $0020           ; Offset Horizontal
