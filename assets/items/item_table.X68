    include './assets/items/gems_h.X68'
    include './assets/items/moguren.X68'
    include './assets/items/chicken.X68'
    include './assets/items/chipmunk.X68'

Game_ItemTable:
    dc.l    GemsH_Update
    dc.l    $0
    dc.l    Moguren_Update
    dc.l    Chicken_Update
    dc.l    Chipmunk_Update