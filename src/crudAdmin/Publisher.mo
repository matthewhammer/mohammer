import Debug "mo:stdlib/debug";
import PS "Pubsub";

actor Publisher {

  var subscriber : ?(Principal, PS.Subscriber) = null;

  public func notifySubscriber() {
    switch subscriber {
      case null {
             Debug.print ("Publisher.notifySubscriber(): no one to notify.");
           };
      case (?(id, s)) {
             Debug.print ("Publisher.notifySubscriber(): notifying subscriber.");
             s.notify()
           };
    }
  };

  // returns true if the subscriber is new; false if already subscribed.
  public shared(msg) func subscribe(s : PS.Subscriber) : async Bool {
    Debug.print "Publisher.subscribe()";
    let res : Bool = switch subscriber {
    case null { true };
    case (?(id0, _)) { id0 != msg.caller };
    };
    subscriber := ?(msg.caller, s);
    res
  };
}
