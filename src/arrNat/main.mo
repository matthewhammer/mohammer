import Array "mo:stdlib/array";
actor {

  type ArrNat = 
    { #imm : [Nat] 
    ; #mut : [var Nat] 
    };

  var arrNat : ArrNat = ( (#imm([])) : ArrNat );
  
  public func clear() {
    arrNat := ( #imm([]) : ArrNat );
  };

  public func clearMut() {
    arrNat := ( #mut([var] : [var Nat]) : ArrNat );
  };

  public func show() : async [Nat] {
    switch arrNat {
      case (#imm a) a;
      case (#mut a) Array.freeze<Nat>(a);
    }
  };

  public func showFull() : async ({#imm; #mut}, [Nat]) {
    switch arrNat {
      case (#imm a) (#imm, a);
      case (#mut a) (#mut, { Array.freeze<Nat> a });
    }
  };

  public func getIndex(i:Nat) : async Nat {
    switch arrNat {
      case (#imm a) a[i];
      case (#mut a) a[i];
    }
  };

  public func setIndex(i:Nat, n:Nat) {
    switch arrNat {
    case (#mut a) { a[i] := n };
    case (#imm a) { 
           // a design choice: 
           // we convert to #mut form here:
           let b = Array.tabulateVar<Nat>(
             a.len(),
             func (j:Nat) {
               if (i == j) {
                 n
               } else {
                 a[j]
               }
             });
           arrNat := #mut b;
         };
    };
  };

  public func set(b:[Nat]) {
    arrNat := #imm b
  };

  public func len() : async Nat {
    switch arrNat {
      case (#mut(a)) {
             a.len()
           };
      case (#imm(a)) {
             a.len()
           };
    }
  };

  public func push(n:Nat) {
    switch arrNat {
    case (#mut(a)) {
           let b = Array.tabulateVar<Nat>(
             a.len() + 1,
             func (i:Nat) {
               if (i < a.len()) {
                 a[i]
               } else {
                 n
               }
             });
           arrNat := #mut b;
         };
    case (#imm(a)) {
           let b = Array.tabulate<Nat>(
             a.len() + 1,
             func (i:Nat) {
               if (i < a.len()) {
                 a[i]
               } else {
                 n
               }
             });
           arrNat := #imm b;
         };
    }
  }
};
