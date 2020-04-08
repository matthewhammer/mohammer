import Debug "mo:stdlib/debug";

// import Publisher "Publisher"; // --- "type error, non-static expression in library or module"

actor Subscriber {  
  public func subscribeSelf() {
    // STUCK -- Need Publisher to be known statically here:
    //Publisher.subscribe(Subscriber);
  };
};
