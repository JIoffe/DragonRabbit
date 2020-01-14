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
    dc.w    $0001
        dc.w    $0001
            dc.w    $0048       ; Bomb
            dc.w    $0158       ; Gem     
    dc.w    $0050
        dc.w    $0000
            dc.w    $0168       ; Gem   

    dc.w    $0060
        dc.w    $0000
            dc.w    $0178       ; Gem   

    dc.w    $0070
        dc.w    $0000
            dc.w    $0188       ; Gem  
    ; END
    dc.w    $FFFF