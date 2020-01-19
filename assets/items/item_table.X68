    include './assets/items/gems.X68'
    include './assets/items/goalflag.X68'
    include './assets/items/moguren.X68'
    include './assets/items/chicken.X68'
    include './assets/items/chipmunk.X68'

Game_ItemTable:
    dc.l    GemsH_Update
    dc.l    GemsV_Update
    dc.l    Moguren_Update
    dc.l    Chicken_Update
    dc.l    Chipmunk_Update
    dc.l    GoalFlag_Update