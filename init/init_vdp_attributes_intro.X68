; Send to vdp_command port at $C00004
VDPSetupArray:
 dc.w  $8004       ;Color=9bit, H/V=disabled, HBlank=disabled
 dc.w  $8174       ;Height=V28 NTSC, DMA=enabled, VBlank=enabled
 dc.w  $8230       ;PLANE A Address=C000
 dc.w  $8340       ;WINDOW Address=10000
 dc.w  $8407       ;PLANE B Address=E000
 dc.w  $855C       ;SPRITE TABLE Address=B800
 dc.w  $8600       ;(unused)
 dc.w  $8700       ;Backdrop Palette=0, Color=0
 dc.w  $8800       ;(unused)
 dc.w  $8900       ;(unused)
 dc.w  $8AFF       ;H Interrupt Every 255 lines (Never happens!)
 dc.w  $8B03       ;VSCROLL=full, HSCROLL=line, EXT. INT=disabled
 dc.w  $8C81       ;H Cells=h40, SHADOW/HIGHLIGHT=disabled, Interlace=disabled
 dc.w  $8D2F       ;H Scroll Table Address=BC00
 dc.w  $8E00       ;(unused))
 dc.w  $8F02       ;VDP Auto Increment 2 bytes
 dc.w  $9001       ;Scroll Plane Size=H64 V32 Cells
 dc.w  $9100       ;Window 0 from left
 dc.w  $9200       ;Window 0 from top
 dc.w  $93FF       ;DMA Size=65535
 dc.w  $947F       ;DMA Source=0
 dc.w  $9500 
 dc.w  $9600 
 dc.w  $9700       ;DMA Mode=ramtovram


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
