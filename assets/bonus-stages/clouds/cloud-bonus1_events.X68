*********************************************
* Events for the bonus stage
* (Mostly when the bombs or gems will come)
* Format is:
*   - Word - frame to load event
*   - word - (number of objects - 1) to add in event
*   - For each object:
*   -- Word - TTXX - Type and X position divided by 2
*   - $FFFF = END STREAM


BonusEvents1:
 dc.w  60  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  90  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  120  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  140  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0178
 dc.w  160  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0198
 dc.w  180  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0178
 dc.w  200  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0198
 dc.w  260  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0088
    dc.w  $0160
 dc.w  280  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $00D0
    dc.w  $00B8
 dc.w  320  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0040
    dc.w  $0058
 dc.w  360  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00D0
 dc.w  370  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00C0
 dc.w  380  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00B0
 dc.w  390  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00A0
 dc.w  400  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  440  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0040
 dc.w  450  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0050
    dc.w  $0188
 dc.w  460  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0060
 dc.w  470  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0070
 dc.w  480  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0080
 dc.w  490  ; KEYFRAME
   dc.w  3 ; (n-1) items
    dc.w  $0090
    dc.w  $00D0
    dc.w  $00C0
    dc.w  $01A8
 ; END
 dc.w $FFFF

