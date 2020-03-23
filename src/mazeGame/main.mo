import Array "mo:stdlib/array";
import Result "mo:stdlib/result";
import Render "../render/render";
import Types "types";
import State "state";

actor {

  var state = State.initState();
  
  public func init() : async Types.ResOut {
    state := State.initState();
    resOut(#ok)
  };

  public func move(dir:Types.Dir2D) : async Types.ResOut  {
    switch (State.move(state, dir)) {
      case (#ok(_)) { resOut(#ok) };
      case (#err(_)) { resOut(#err) };
    }
  };

  public func multiMove(dir:[Types.Dir2D]) : async Types.ResOut {
    switch (State.multiMove(state, dir)) {
      case (#ok(_)) { resOut(#ok) };
      case (#err(_)) { resOut(#err) };
    }
  };

  func resOut(status:{#ok; #err}) : Types.ResOut {
    let elms = State.render(state);
    switch status {
      case (#ok) { #ok(elms) };
      case (#err) { #err(elms) };
    }
  }
  
};
