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
* Embedded: FALSE
* Tiles to Allocate: 32
GoalFlag:
    GoalFlag_Unrolled:
    dc.w $0000           ; frame count
    dc.l GoalFlag_Unrolled0
    GoalFlag_Unrolled0:
        dc.w $0003
        dc.w $0000           ; Offset Vertical
        dc.w $0F00     ; sprite Size
        dc.w $0055           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0020           ; Offset Vertical
        dc.w $0E00     ; sprite Size
        dc.w $0065           ; sprite tile ID
        dc.w $0000           ; Offset Horizontal
        dc.w $0038           ; Offset Vertical
        dc.w $0000     ; sprite Size
        dc.w $0071           ; sprite tile ID
        dc.w $0C0C           ; Offset Horizontal
        dc.w $0040           ; Offset Vertical
        dc.w $0800     ; sprite Size
        dc.w $0072           ; sprite tile ID
        dc.w $0404           ; Offset Horizontal



; Level Effects
ChickenFeathers:
   dc.w $0500
   dc.w $019E

NutProjectile:
   dc.w $0500
   dc.w $0285
