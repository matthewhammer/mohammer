import List "mo:stdlib/list";
import Result "mo:stdlib/result";
import Render "../render/render";

module {

public type Tile = {
  #void;
  #start;
  #goal;
  #floor;
  #wall;
  // locks opened with matching keys; consumes key.
  #lock : Id;
  #key : Id;
  // inward portals lead to the (unique) matching outward portal
  #inward : Id;
  #outward : Id;
};

public type Room = {
  width : Nat;
  height : Nat;
  tiles : [[var Tile]];
};

public type Pos = {
  room : Nat;
  tile : (Nat, Nat);
};

public type Maze = {
  start : Pos;
  goal : Pos;
  rooms : [Room];
};

public type Dir2D = {#up; #down; #left; #right};

// full game state:
public type State = {
  var keys: List.List<Id>;
  var maze: Maze;
  var pos: Pos;
  var won: Bool;
};

// move results back to game client:
public type ResOut = Result.Result<Render.Out, Render.Out>;

// Ids are numbers, strings, and "tagged tuples" made of those primitives:
// (see also: CleanSheets 'Name' type for sheet-cells)
public type Id = {
  #nat : Nat;
  #text : Text;
  #tagTup : (Id, [Id]);
};

public func idEq(n1:Id, n2:Id) : Bool {
  switch (n1, n2) {
  case (#nat(n1), #nat(n2)) { n1 == n2 };
  case (#text(t1), #text(t2)) { t1 == t2 };
  case (#tagTup(tag1, tup1), #tagTup(tag2, tup2)) {
         if (idEq(tag1, tag2)) {
           if (tup1.len() == tup2.len()) {
             for (i in tup1.keys()) {
               if(idEq(tup1[i], tup2[i])) {
                 // continue checking...
               } else { return false }
             }; true
           } else { false };
         } else { false };
       };
  case (_, _) { false };
  }
};

}
