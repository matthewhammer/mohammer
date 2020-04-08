import Debug "mo:stdlib/debug";
import Publisher "canister:Publisher";

actor Subscriber {

  public func notify() : () {
    Debug.print "Subscriber.notify()";
  };

  public func subscribeSelf() : async Bool {
    Debug.print "gSubscriber.subscribeSelf()";
    await Publisher.subscribe(Subscriber);
  };
};
