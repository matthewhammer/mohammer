import P "mo:stdlib/prelude";
import Render "../render/render";

module {
  public type Comp = {
    #lt;
    #eq;
    #gt;
  };

  public type Color = {#R; #B};

  public type Tree<X, Y> = {
    #node : (Color, X, Y, Tree<X, Y>, Tree<X, Y>);
    #leaf;
  };

  public class RBTree<X, Y>(compareTo:(X, X) -> Comp) {

    var tree: Tree<X, Y> = (#leaf : Tree<X, Y>);

    // Get non-OO, purely-functional representation:
    // for drawing, pretty-printing and non-OO contexts
    // (e.g., async args and results):
    public func getTree() : Tree<X, Y> {
      tree
    };

    public func find(x:X) : ?Y =
      findRec(x, tree);

    public func insert(x:X, y:Y) : ?Y {
      let (res, t) = insertRec(x, y, tree);
      tree := t;
      res
    };

    public func remove(x:X) : ?Y {
      // to do
      P.xxx()
    };
    

    func rebal(t:Tree<X, Y>) : Tree<X, Y> {
      // to do
      t
    };

    func insertRec(x1:X, y1:Y, t:Tree<X, Y>)
      : (?Y, Tree<X, Y>)
    {
      switch t {
      case (#leaf) { (null, #leaf) };
      case (#node(c, x2, y2, l, r)) {
             switch (compareTo(x1, x2)) {
             case (#lt) {
                    let (yo, l2) = insertRec(x1, y1, l);
                    (yo, rebal(#node(c, x2, y2, l2, r)))
                  };
             case (#eq) {
                    (?y2, #node(c, x1, y1, l, r))
                  };
             case (#gt) {
                    let (yo, r2) = insertRec(x1, y1, r);
                    (yo, rebal(#node(c, x2, y2, l, r2)))
                  };
             }
           }
      }
    };

    func findRec(x1:X, t:Tree<X, Y>) : ?Y {
      switch t {
      case (#leaf) { null };
      case (#node(c, x2, y, l, r)) {
             switch (compareTo(x1, x2)) {
             case (#lt) { findRec(x1, l) };
             case (#eq) { ?y };
             case (#gt) { findRec(x1, r) };
             }
           };
      }
    };
  };

  public func drawTree<X, Y>(
    tree: Tree<X, Y>,
    drawX: X -> Render.Elm,
    drawY: Y -> Render.Elm,
  ) : Render.Elm
  {
    P.xxx()
  };
}
