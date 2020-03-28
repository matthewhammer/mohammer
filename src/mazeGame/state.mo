import List "mo:stdlib/list";
import Result "mo:stdlib/result";
import Render "../render/render";
import Types "types";

module {
  
  type State = Types.State;
  type Dir2D = Types.Dir2D;
  type Pos = Types.Pos;
  type Tile = Types.Tile;

  public func render(st:State) : Render.Elm {
    let legendPad = { dir=#right;
                      interPad=20;
                      intraPad=20;
    };
    let textHorz = { dir=#right;
                     interPad=1;
                     intraPad=1;
    };
    let horz = { dir=#right;
                 interPad=0;
                 intraPad=0;
    };
    let vert = { dir=#down;
                 interPad=0;
                 intraPad=0;
    };
    func tileAtts(fg:Render.Fill, bg:Render.Fill) : Render.TextAtts = {
      {
        zoom=4;
        fgFill=fg;
        bgFill=bg;
        glyphDim={width=5;height=5};
        glyphFlow=horz;
      }
    };
    
    func taLegend(fg:Render.Fill) : Render.TextAtts = 
      {
        zoom=2;
        fgFill=fg;
        bgFill=#closed((0, 0, 0));
        glyphDim={width=5;height=5};
        glyphFlow=textHorz;
      };
    let taLegendText = taLegend(#closed((200, 200, 200)));

    let bgFill = #closed((50, 10, 50));
    let taVoid = tileAtts(#none, #none);
    let taPlayer = tileAtts(#closed((255, 255, 255)), bgFill);
    let taStart = tileAtts(#closed((255, 100, 255)), bgFill);
    let taGoal = tileAtts(#closed((255, 240, 255)), bgFill);
    let taWall = tileAtts(#closed((200, 100, 200)), bgFill);
    let taFloor = tileAtts(#closed((200, 100, 200)), bgFill);
    let taLock = tileAtts(#closed((200, 200, 100)), bgFill);
    let taKey = tileAtts(#closed((255, 255, 100)), bgFill);

    let r = Render.Render();
    let room_tiles = st.maze.rooms[st.pos.room].tiles;
    
    r.begin(#flow(horz)); // Display begin

    r.begin(#flow(vert)); // Legend begin
    r.begin(#flow(vert));
    //r.rect({pos={x=0;y=0};dim={width=150;height=10}}, #none);
    r.begin(#flow(horz));
    r.begin(#flow(vert));                 
    r.text("(", taLegendText);
    r.end();
    r.begin(#flow(vert));                 
    r.text(debug_show st.pos.tile.1, taLegendText);
    r.end();
    r.begin(#flow(vert));                 
    r.text(",", taLegendText);
    r.end();
    r.begin(#flow(vert));                 
    r.text(debug_show st.pos.tile.0, taLegendText);
    r.end();
    r.begin(#flow(vert));
    r.text(")", taLegendText);
    r.end();
    r.end();

    r.begin(#flow(vert)); // Keys begin
    //r.rect({pos={x=0;y=0};dim={width=150;height=10}}, #none);
    r.text("keys:", taLegendText);
    r.end();
    r.begin(#flow(horz));
    switch (st.keys) {
      case null { r.text("none", taLegendText) };
      case (?_) {
             List.iter<Types.Id>(st.keys,
               func (_:Types.Id) {
                 r.begin(#flow(vert));
                 r.text("ķ", taLegend(#closed((255, 255, 100))));
                 r.end();
               })
           };
    };
    r.end();
    r.end(); // Keys end
    r.end(); // Legend end

    r.begin(#flow(vert)); // Map begin
    var i = 0;
    for (row in room_tiles.vals()) {
      var j = 0;
      r.begin(#flow(horz));
      for (tile in row.vals()) {
        r.begin(#flow(horz));
        if (j == st.pos.tile.0 
        and i == st.pos.tile.1) {
          r.text("☺", taPlayer)
        } else {
          switch tile {
          case (#void) { r.text(" ", taVoid) };
          case (#start) { r.text("◊", taStart) };
          case (#goal) { r.text("⇲", taGoal) };
          case (#floor) { r.text(" ", taFloor) };
          case (#wall) { r.text("█", taWall) };
          case (#lock(_)) { r.text("ļ", taLock) };
          case (#key(_)) { r.text("ķ", taKey) };
          case (#inward(_)) { r.text("i", taWall) };
          case (#outward(_)) { r.text("o", taWall) };          
          };
        };
        r.end();
        j += 1;
      };
      r.end();
      i += 1;
    };
    r.end(); // Map end
    r.end(); // Display end
    r.getElm()
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

  public func setTile(st:State, pos:Pos, newTile:Tile) : ?Tile {
    let room = st.maze.rooms[pos.room];
    // address y pos (row), then x pos (column):
    if (pos.tile.1 < room.height and pos.tile.0 < room.width) {
      let oldTile = room.tiles[pos.tile.1][pos.tile.0];
      room.tiles[pos.tile.1][pos.tile.0] := newTile;
      ?oldTile
    } else {
      null
    }
  };

  public func getNeighborTile(st:State, dir:Dir2D) : ?Tile {
    getTile(st, movePos(st.pos, dir))
  };

  public func updateNeighborTile(st:State, dir:Dir2D, tile:Tile) : ?Tile {
    setTile(st, movePos(st.pos, dir), tile)
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
             ignore updateNeighborTile(st, dir, #floor);
             st.pos := movePos(st.pos, dir);
             st.keys := ?(id, st.keys);
             #ok(())
           };
      case (?#lock(id)) {
             switch (st.keys) {
             case null { #err(()) };
             case (?(_key, keys)) { 
                    ignore updateNeighborTile(st, dir, #floor);
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
      case (?#void) {
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
    let x = #void;
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

    // compiler issue?: cannot inline this let binding; why?
    let _tiles : [[ var Tile ]] = [
      [ var w, s, w, x,  x, x, x, x,  w, w, w, w ],
      [ var w, k, w, x,  x, x, w, x,  w, l, l, g ],
      [ var w, l, w, x,  x, w, f, w,  w, l, w, w ],
      [ var w, k, w, x,  x, w, f, f,  f, l, f, w ],

      [ var w, k, w, x,  w, w, l, w,  f, f, f, w ],
      [ var w, l, w, x,  w, l, f, w,  w, w, f, w ],
      [ var w, l, w, x,  w, l, l, w,  x, w, f, w ],
      [ var w, f, w, w,  w, l, f, w,  x, w, f, w ],
      
      [ var w, f, f, f,  l, f, f, w,  w, f, f, w ],
      [ var w, f, w, w,  w, w, f, w,  k, k, f, w ],
      [ var w, f, k, w,  k, k, f, w,  k, k, f, w ],
      [ var w, w, w, w,  w, w, w, w,  w, w, w, x ],            
    ];
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
              height=12;
              tiles=_tiles;
            }                 
          ];
        }
    }
  };
}
