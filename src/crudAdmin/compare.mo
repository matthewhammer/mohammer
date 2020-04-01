module {
  
  public type Comp = {#lt; #eq; #gt};

  public func compareNats(x:Nat, y:Nat) : Comp {
    if (x == y) { #eq } 
    else if (x > y) { #gt } 
    else #lt
  };

  module FBoundedApproach {
    
    public type Compare<X> = {
      compareTo : X -> Comp;
    };
    
    public class Apple(n:Nat) {
      // I want this field to be private, but then `compareTo` will not type-check.
      public var appleId = n;
      public func compareTo (other:Apple) : Comp {
        compareNats(appleId, other.appleId)
      };
    };

    public func checkApple(x:Apple) : Compare<Apple> { x };
    
    public class Orange(n:Nat) {
      // I want this field to be private, but then `compareTo` will not type-check.      
      public var orangeId = n;      
      public func compareTo (other:Orange) : Comp {
        compareNats(orangeId, other.orangeId)
      };
    };
    
    public func checkOrange(x:Orange) : Compare<Orange> { x };
    
    public type Fruit = Compare<Fruit>;
    public func makeBasket(x:Apple, y:Orange) : [Fruit] {
      let basket = [x, y];
      for (a in basket.vals()) {
        for (b in basket.vals()) {
          // In this variation, this call will not type-check:
          // The function expects a _specific_ fruit.
          
          // ignore a.compareTo(b)
          assert false
        }
      };
      // What type does basket have?
      // Can I write it in the type system?
      // How do I write `@glb(Apple, Orange)` in the type system?
      loop { }
    };
  };

  // Here's an attempt to write a common super-type `Compare`; 
  // it doesn't actually work out this way.
  module SuperTypeApproach {
    
    public type Compare = {
      compareTo : Compare -> Comp;
    };
    
    public class Apple(n:Nat) {
      var appleId = n;
      public func compareTo (other:Apple) : Comp {
	      // Want:
        //   appleId == other.appleId
        // But:
        //   "type error, field appleId does not exist in type {compareTo : Apple -> Comp}"
        assert false;
        #eq
      };
    };

    public func checkApple(x:Apple) : Compare { x };
    
    public class Orange(n:Nat) {
      var orangeId = n;      
      public func compareTo (other:Orange) : Comp {
	      // Want:
        //   orangeId == other.orangeId
        // But:
        //   "type error, field orangeId does not exist in type {compareTo : Orange -> Comp}"
        assert false;
        #eq
      };
    };
    
    public func checkOrange(x:Orange) : Compare { x };

    public func makeBasket(x:Apple, y:Orange) : [Compare] {
      let basket = [x, y];

      // We _can_ compare all of the elements to all of the others, but
      // as we see above, nothing is _really_ happening during that
      // comparison, since we cannot really access anything that is
      // relevant:

      for (a in basket.vals()) {
        for (b in basket.vals()) {
          ignore a.compareTo(b)
        }
      };

      basket
    };
  };
}
