actor {

  var n = 0;

  public func getCount() : async Nat { n };
  
  public func incCount() : async Nat { n += 1; n };

  public func greet(t:Text) : async Text {
    "hello " # t # "!"
  };

}
