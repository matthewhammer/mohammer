actor {
    var counter = 0;

    public func get() : async Nat { counter };
    public func set(n:Nat) { counter := n };

    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };
};
