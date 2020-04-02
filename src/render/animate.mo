import P "mo:stdlib/prelude";
import Movm "movm";
import Render "render";

module {
  // a _duration_ in time; 1 unit is the smallest duration.
  public type Dur = Nat;

  public type Elms = [Render.Elm];

  public type Anim = Movm.State;

  public func simpleFlipBook(elms:Elms, pageDur:Dur) : Anim {
    // A simple, looping VM that consumes a stream of ticks and 
    // returns a stream of corresponding elements to render
    P.xxx()
  };



}
