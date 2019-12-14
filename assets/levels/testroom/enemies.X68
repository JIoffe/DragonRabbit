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
        dc.w $0000           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $0108           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0020           ; Offset Vertical
        dc.w $0800     ; sprite Size
        dc.w $0118           ; sprite tile ID
        dc.w $0503           ; Offset Horizontal
    Moguren_Walking1:
        dc.w $0001
        dc.w $0000           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $011B           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0020           ; Offset Vertical
        dc.w $0400     ; sprite Size
        dc.w $012B           ; sprite tile ID
        dc.w $0907           ; Offset Horizontal
    Moguren_Hurt:
    dc.w $0000           ; frame count
    dc.l Moguren_Hurt0
    Moguren_Hurt0:
        dc.w $0001
        dc.w $0008           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $012D           ; sprite tile ID
        dc.w $1000           ; Offset Horizontal
        dc.w $0008           ; Offset Vertical
        dc.w $0600     ; sprite Size
        dc.w $013D           ; sprite tile ID
        dc.w $0020           ; Offset Horizontal
**************************************************
* Compression: NONE
* Embedded: FALSE
* Tiles to Allocate: 12
Chicken:
    Chicken_Walking:
    dc.w $0001           ; frame count
    dc.l Chicken_Walking0
    dc.l Chicken_Walking1
    Chicken_Walking0:
        dc.w $0001
        dc.w $0000           ; Offset Vertical
        dc.w $0600     ; sprite Size
        dc.w $017E           ; sprite tile ID
        dc.w $000B           ; Offset Horizontal
        dc.w $0005           ; Offset Vertical
        dc.w $0500     ; sprite Size
        dc.w $0184           ; sprite tile ID
        dc.w $10FB           ; Offset Horizontal
    Chicken_Walking1:
        dc.w $0001
        dc.w $0000           ; Offset Vertical
        dc.w $0600     ; sprite Size
        dc.w $0188           ; sprite tile ID
        dc.w $FF0C           ; Offset Horizontal
        dc.w $0005           ; Offset Vertical
        dc.w $0500     ; sprite Size
        dc.w $018E           ; sprite tile ID
        dc.w $0FFC           ; Offset Horizontal
    Chicken_Hurt:
    dc.w $0000           ; frame count
    dc.l Chicken_Hurt0
    Chicken_Hurt0:
        dc.w $0000
        dc.w $0000           ; Offset Vertical
        dc.w $0E00     ; sprite Size
        dc.w $0192           ; sprite tile ID
        dc.w $FFFC           ; Offset Horizontal
**************************************************
