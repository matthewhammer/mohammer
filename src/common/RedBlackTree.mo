import P "mo:stdlib/prelude";
import Render "../render/render";

module {
  public type Comp = {
    #lt;
    #eq;
    #gt;
  };

  public type Color = {#R; #B};

  public type Tree<X> = {
    #node : (Color, X, Tree<X>, Tree<X>);
    #leaf;
  };

  public class RBTree<X>(compareTo:(X, X) -> Comp) {
    
    var tree: Tree<X> = (#leaf : Tree<X>);

    public func find(x:X) : ?X = 
      findRec(x, tree);

    func findRec(x:X, t:Tree<X>) : ?X {
      switch tree {
      case (#leaf) { null };
      case (#node(c, y, l, r)) {
             switch (compareTo(x, y)) {
             case (#lt) { findRec(x, l) };
             case (#eq) { ?y };
             case (#gt) { findRec(x, r) };
             }
           };
      }
    };    
    
    // Non-OO representation: 
    // for drawing, pretty-printing and non-OO contexts
    // (e.g., async args and results):
    public func getTree() : Tree<X> {
      tree
    }
  };

  public func draw<X>(tree:Tree<X>) : Render.Elm {
    P.xxx()
  };
}
