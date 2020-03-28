import Array "mo:stdlib/array";
import Result "mo:stdlib/result";
import Render "../render/render";
import Types "types";
import State "state";
import Draw "draw";

actor {

  var state = State.initState();

  public func draw() : async Types.ResOut {
    resOut(#ok)
  };
  
  public func reset() : async Types.ResOut {
    state := State.initState();
    resOut(#ok)
  };
  
  public func move(dir:Types.Dir2D) : async {#ok; #err} {
    switch (State.move(state, dir)) {
      case (#ok(_)) { #ok };
      case (#err(_)) { #err };
    }
  };

  public func moveDraw(dir:Types.Dir2D) : async Types.ResOut  {
    switch (State.move(state, dir)) {
      case (#ok(_)) { resOut(#ok) };
      case (#err(_)) { resOut(#err) };
    }
  };

  public func moveStarDraw(dir:Types.Dir2D) : async Types.ResOut  {
    loop {
      switch (State.move(state, dir)) {
        case (#ok(_)) { };
        case (#err(_)) { return resOut(#ok) };
      }
    }
  };

  public func move2(dir1:Types.Dir2D, dir2:Types.Dir2D) : async Types.ResOut  {
    _moveN([dir1, dir2])
  };


  func _moveN(dir:[Types.Dir2D]) : Types.ResOut {
    switch (State.multiMove(state, dir)) {
      case (#ok(_)) { resOut(#ok) };
      case (#err(_)) { resOut(#err) };
    }
  };

  func resOut(status:{#ok; #err}) : Types.ResOut {
    let elm = Draw.drawState(state);
    let rs : Render.Out = #redraw([("state", elm)]);
    switch status {
      case (#ok) { #ok(rs) };
      case (#err) { #err(rs) };
    }
  }
  
};
