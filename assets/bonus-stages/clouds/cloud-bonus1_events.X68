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
 dc.w  520  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $01A8
 dc.w  550  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $01A8
    dc.w  $00C8
    dc.w  $0088
 dc.w  590  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $0198
    dc.w  $00B8
    dc.w  $0078
 dc.w  630  ; KEYFRAME
   dc.w  4 ; (n-1) items
    dc.w  $0188
    dc.w  $00A8
    dc.w  $0068
    dc.w  $0040
    dc.w  $00D0
 dc.w  650  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0068
    dc.w  $00A8
 dc.w  670  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  690  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0170
    dc.w  $01A0
 dc.w  720  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0160
    dc.w  $01B0
 dc.w  750  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $0088
    dc.w  $01C8
    dc.w  $0148
 dc.w  760  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0078
    dc.w  $0098
 dc.w  770  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0068
    dc.w  $00A8
 dc.w  780  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0098
    dc.w  $0078
 dc.w  800  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0078
    dc.w  $0098
 dc.w  830  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0148
    dc.w  $01C8
 dc.w  860  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $01B8
    dc.w  $0158
    dc.w  $0088
 dc.w  890  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0168
    dc.w  $01A8
 dc.w  920  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  1030  ; KEYFRAME
   dc.w  4 ; (n-1) items
    dc.w  $00D0
    dc.w  $0040
    dc.w  $0160
    dc.w  $01B0
    dc.w  $0088
 dc.w  1080  ; KEYFRAME
   dc.w  4 ; (n-1) items
    dc.w  $0188
    dc.w  $0060
    dc.w  $00B0
    dc.w  $0140
    dc.w  $01D0
 dc.w  1130  ; KEYFRAME
   dc.w  4 ; (n-1) items
    dc.w  $00D0
    dc.w  $0088
    dc.w  $0040
    dc.w  $0160
    dc.w  $01B0
 dc.w  1160  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $0088
    dc.w  $0040
    dc.w  $00D0
 dc.w  1210  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  1230  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0178
    dc.w  $0198
 dc.w  1250  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0168
    dc.w  $01A8
 dc.w  1270  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0158
    dc.w  $01B8
 dc.w  1290  ; KEYFRAME
   dc.w  3 ; (n-1) items
    dc.w  $0148
    dc.w  $01D0
    dc.w  $0080
    dc.w  $0090
 dc.w  1310  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0158
    dc.w  $01B8
 dc.w  1330  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0168
    dc.w  $01A8
 dc.w  1350  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0178
    dc.w  $0198
 dc.w  1380  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0188
    dc.w  $0040
 dc.w  1410  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0178
    dc.w  $0198
 dc.w  1420  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00D0
 dc.w  1460  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0188
    dc.w  $0040
 dc.w  1490  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0178
    dc.w  $0198
 dc.w  1500  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $00D0
 dc.w  1570  ; KEYFRAME
   dc.w  0 ; (n-1) items
    dc.w  $0188
 dc.w  1610  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0080
    dc.w  $0090
 dc.w  1690  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $0140
    dc.w  $01D0
    dc.w  $0188
 dc.w  1710  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $01A8
    dc.w  $0168
 dc.w  1730  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $01D0
    dc.w  $0140
    dc.w  $0188
 dc.w  1750  ; KEYFRAME
   dc.w  1 ; (n-1) items
    dc.w  $0168
    dc.w  $01A8
 dc.w  1770  ; KEYFRAME
   dc.w  2 ; (n-1) items
    dc.w  $0140
    dc.w  $01D0
    dc.w  $0188
 ; END
 dc.w $FFFF


