import List "mo:stdlib/list";
import Result "mo:stdlib/result";
import Render "../render/render";
import Types "types";

module {
  
  type State = Types.State;
  type Dir2D = Types.Dir2D;
  type Pos = Types.Pos;
  type Tile = Types.Tile;

  public func render(st:State) : Render.Elms {
    let r = Render.Render();
    r.getElms()
  };

  public func getTile(st:State, pos:Pos) : ?Tile {
    let room = st.maze.rooms[pos.room];
    // address y pos (row), then x pos (column):
    if (pos.tile.1 < room.height and pos.tile.0 < room.width) {
      let tile = room.tiles[pos.tile.1][pos.tile.0];
      ?tile
    } else {
      null
    }
  };

  public func getNeighborTile(st:State, dir:Dir2D) : ?Tile {
    getTile(st, movePos(st.pos, dir))
  };

  public func move(st:State, dir:Dir2D) : Result.Result<(), ()> {
    switch (getNeighborTile(st, dir)) {
      case null {
             #err(())
           };
      case (?#floor) { 
             st.pos := movePos(st.pos, dir);
             #ok(())
           };
      case (?#key(id)) {
             st.pos := movePos(st.pos, dir);
             st.keys := ?(id, st.keys);
             #ok(())
           };
      case (?#lock(id)) {
             switch (st.keys) {
             case null { #err(()) };
             case (?(_key, keys)) { 
                    // use last key; to do: search for matching keys by Id...
                    st.keys := keys; 
                    st.pos := movePos(st.pos, dir);
                    #ok(())
                  };
             }
           };
      case (?#wall) {
             #err(())
           };
      case (?#goal) {
             st.won := true;
             st.pos := movePos(st.pos, dir);
             #ok(())
           };
      case (?#start) {
             st.pos := movePos(st.pos, dir);
             #ok(())
           };
      case (?#outward(_)) {
             st.pos := movePos(st.pos, dir);
             #ok(())
           };
      case (?#inward(_)) {
             st.pos := movePos(st.pos, dir);
             #ok(())
             // to do -- search for matching outward portal, 
             // ...and teleport!
           };
    }
  };
  
  public func movePos(pos:Pos, dir:Dir2D) : Pos {
    let (xPos, yPos) = (pos.tile.0, pos.tile.1);
    let newTilePos = switch dir {
    case (#up) { (xPos, if (yPos > 0) {yPos-1} else { 0 }) };
    case (#down) { (xPos, yPos+1) };
    case (#left) { (if (xPos > 0) {xPos - 1} else { 0 }, yPos) };
    case (#right) { (xPos+1, yPos) };
    };
    { room= pos.room;
      tile=newTilePos }
  };

  public func multiMove(st:State, dirs:[Dir2D]) : Result.Result<(), ()> {
    for (dir in dirs.vals()) {
      switch (move(st, dir)) {
        case (#ok(())) { };
        case (#err(())) { return #err(()) };
      };
    };
    #ok(())
  };
  
  public func initState() : Types.State {
    // tile palette for example maze
    let s = #start;
    let g = #goal;
    let f = #floor;
    let w = #wall;
    let l = #lock(#nat(0));
    let k = #key(#nat(0));
    let i = #inward(#nat(1));
    let o = #outward(#nat(1));

    { 
      var keys = List.nil<Types.Id>();
      var won = false;
      var pos = { tile=(0,0); room=0 };
      var maze : Types.Maze = {
        start = { room = 0;
                  tile = (1, 1);
        };
        goal = { room = 0;
                 tile = (6, 6);
        };
        rooms = [
          {
            width=8;
            height=8;
            tiles=[
              [ w, w, w, w,  w, w, w, w ],
              [ w, s, k, w,  f, l, g, w ],
              [ w, l, w, w,  f, l, l, w ],
              [ w, f, w, f,  w, f, f, w ],
              
              [ w, f, f, f,  l, f, f, w ],
              [ w, f, w, w,  w, w, f, w ],
              [ w, f, k, w,  k, f, f, w ],
              [ w, w, w, w,  w, w, w, w ],            
            ]
          }                 
        ];
      }
    }
  };
}
