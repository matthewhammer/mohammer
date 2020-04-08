import Debug "mo:stdlib/debug";

actor Publisher {
  
  public type Subscriber = actor {
    notify : () -> ()
  };

  var subscriber : ?(Principal, Subscriber) = null;
  
  public shared(msg) func subscribe() : async Bool {
    let s : Subscriber = {
      // (msg.caller : Subscriber)  ---- Not permitted.
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
