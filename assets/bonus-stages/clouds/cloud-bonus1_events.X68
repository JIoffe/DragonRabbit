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
            dc.w    $0068       ; Bomb   

    dc.w    $0060
        dc.w    $0000
            dc.w    $0078       ; Bomb   

    dc.w    $0070
        dc.w    $0000
            dc.w    $0088       ; Bomb  

    dc.w    $00A0
        dc.w    $0000
            dc.w    $0068       ; Bomb   

    dc.w    $00C0
        dc.w    $0000
            dc.w    $0078       ; Bomb   

    dc.w    $00E0
        dc.w    $0000
            dc.w    $0088       ; Bomb  
    ; END
    dc.w    $FFFF