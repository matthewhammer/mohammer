import PS "Pubsub";

actor Publisher {
  
  var subscriber : ?(Principal, PS.Subscriber) = null;

  // use explicit caller arg to record the subscribing actor's ID
  public shared(msg) func subscribeExplicit(s : PS.Subscriber) : async Bool {
    let res : Bool = switch subscriber {
    case null { false };
    case (?(id0, _)) {
           // Caution:
           // Unchecked equality assumed: (s : Text) == msg.caller.
           id0 == msg.caller
         };
    };
    subscriber := ?(msg.caller, s);
    res
  };

  // use implicit caller arg to record the subscribing actor's ID
  public shared(msg) func subscribeImplicit() : async Bool {
    let s : PS.Subscriber = {
      // Stuck:
      // (msg.caller : Subscriber)  ---- Not permitted.
      assert false;
      loop { }
    };
    let res : Bool = switch subscriber {
    case null { false };
    case (?(id0, _)) { id0 == msg.caller };
    };
    subscriber := ?(msg.caller, s);
    res
  };
}
