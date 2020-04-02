import D "mo:stdlib/debug";

module {
  public class Animal(_n:Nat, _f:Nat -> Nat) {
    // We can simply store the params:
    var n1 = _n;
    var f1 = _f;
    // We can also use them in computations, right here:
    var n2 = _n + 1;
    var n3 =_f(_n + 1);
    
    // We can also use the stored versions, of course:
    var n4 = n1 + 1;
    var n5 = f1(n1 + 1);    

    public func printStuff() {
      D.print (debug_show n1);
      D.print (debug_show n2);
      D.print (debug_show n3);
      D.print (debug_show n4);
      D.print (debug_show n5);
    }
  }
}
