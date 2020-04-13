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

  // ----------- Drawing

  func renderColor(c:Color) : Render.Color = {
    switch c {
    case (#R) { (255, 100, 100) };
    case (#B) { (255, 255, 255) };
    }
  };

  func textAtts(c:Color) : Render.TextAtts = {
    zoom=1;
    fgFill=#closed(renderColor(c));
    bgFill=#closed((0,0,0));
    glyphDim={width=5; height=5};
    glyphFlow={
      dir=#right;
      intraPad=1;
      interPad=2
    };
  };

  // "child vs parent" as "down vs "up":
  func parentChildFlow() : Render.FlowAtts =
    {
      dir=#down;
      intraPad=2;
      interPad=2;
    };

  // "sibling-1 vs sibling-2" as "left vs right":
  func siblingSiblingFlow() : Render.FlowAtts =
    {
      dir=#right;
      intraPad=2;
      interPad=2;
    };

  func drawTreeRec<X, Y>(
    r: Render.Render,
    tree: Tree<X, Y>,
    drawXY: (X, Y) -> Render.Elm,
  ) {
    r.beginFlow(parentChildFlow());
    switch tree {
    case (#node (c, x, y, lc, rc)) {
           r.elm(drawXY(x, y));
           r.beginFlow(siblingSiblingFlow());
           // to do: Understand why we cannot currently infer these:
           drawTreeRec<X, Y>(r, lc, drawXY);
           drawTreeRec<X, Y>(r, rc, drawXY);
           r.end();
         };
    case (#leaf) {
           r.begin(#none);
           r.text("*", textAtts(#B));
           r.end();
         };
    };
    r.end()
  };

  public func drawTree<X, Y>(
    tree: Tree<X, Y>,
    drawXY: (X, Y) -> Render.Elm,
  ) : Render.Elm
  {
    let r = Render.Render();
    drawTreeRec(r, tree, drawXY);
    r.getElm()
  };

}
