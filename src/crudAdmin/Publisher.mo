import Debug "mo:stdlib/debug";

actor Publisher {

  public type Subscriber = actor {
    notify : () -> ()
  };

  var subscriber : ?(Principal, Subscriber) = null;

  // use explicit caller arg to record the subscribing actor's ID
  public shared(msg) func subscribeExplicit(s : Subscriber) : async Bool {
    let res : Bool = switch subscriber {
    case null { false };
    case (?(0, _)) {
           // Caution:
           // Unchecked equality assumed: (s : Text) == msg.caller.
           i0 == msg.caller
         };
    };
    subscriber := ?(msg.caller, s);
    res
  };

  // use implicit caller arg to record the subscribing actor's ID
  public shared(msg) func subscribeImplicit() : async Bool {
    let s : Subscriber = {
      // Stuck:
      // (msg.caller : Subscriber)  ---- Not permitted.
      assert false;
      loop { }
    };
    let res : Bool = switch subscriber {
    case null { false };
    case (?(id0, _)) { i0 == msg.caller };
    };
    subscriber := ?(msg.caller, s);
    res
  };
};
