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
    let horz = { dir=#right;
                 interPad=2;
                 intraPad=1;
    };
    let vert = { dir=#down;
                 interPad=2;
                 intraPad=1;
    };
    let textAtts = {
      zoom=1;
      fgFill=#none;
      bgFill=#none;
      glyphDim={width=5;height=5};
      glyphFlow=horz;
    };
    let r = Render.Render();
    let room_tiles = st.maze.rooms[st.pos.room].tiles;
    r.begin(#flow(vert));
    for (row in room_tiles.vals()) {
      r.begin(#flow(horz));
      for (tile in row.vals()) {
        r.begin(#flow(horz));
        let ta = textAtts;        
        switch tile {
          case (#start) { r.text("s", ta) };
          case (#goal) { r.text("g", ta) };
          case (#floor) { r.text("f", ta) };
          case (#wall) { r.text("W", ta) };
          case (#lock(_)) { r.text("L", ta) };
          case (#key(_)) { r.text("k", ta) };
          case (#inward(_)) { r.text("i", ta) };
          case (#outward(_)) { r.text("o", ta) };          
        };
        r.end();
      };
      r.end();
    };
    r.end();
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

  public func posEq(pos1:Pos, pos2:Pos) : Bool {
    pos1.room == pos2.room and
    pos1.tile.0 == pos2.tile.0 and 
    pos1.tile.1 == pos2.tile.1
  };

  public func move(st:State, dir:Dir2D) : Result.Result<(), ()> {
    if (posEq(movePos(st.pos, dir), st.pos)) {
      return #err(())
    };
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

    let startPos = { room = 0;
                     tile = (1, 0) };
    { 
      var keys = List.nil<Types.Id>();
      var won = false;
      var pos = startPos;
      var maze : Types.Maze = 
        {
          start = startPos;
          goal = { room = 0;
                   tile = (6, 6); };
          rooms = [
            {
              width=8;
              height=8;
              tiles=[
                [ w, s, w, w,  w, w, w, w ],
                [ w, f, k, w,  f, l, g, w ],
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
