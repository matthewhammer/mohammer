import Debug "mo:stdlib/debug";
import P "mo:stdlib/prelude";
import ExtNat "Nat";
import Nat "mo:stdlib/nat";
import Render "../render/render";
import I "mo:stdlib/Iter";
import List "mo:stdlib/List";

module {

public type Comp = {
  #lt;
  #eq;
  #gt;
};

public type Color = {#R; #B};

public type Tree<X, Y> = {
  #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>);
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
    findRec(x, compareTo, tree);

  public func insert(x:X, y:Y) : ?Y {
    let (res, t) = insertRoot(x, compareTo, y, tree);
    tree := t;
    res
  };

  public func remove(x:X) : ?Y {
    let (res, t) = removeRec(x, compareTo, tree);
    tree := t;
    res
  };

  // iterator is persistent, like the tree itself;
  public func iter() : I.Iter<(X, Y)> = toIter(tree, #l2r);

  public func rev() : I.Iter<(X, Y)> = toIter(tree, #r2l);

};


type IterRep<X, Y> = List.List<{#tr:Tree<X, Y>; #xy:(X, ?Y)}>;

public func toIter<X, Y>(t:Tree<X, Y>, dir:{#l2r; #r2l}) : I.Iter<(X, Y)> {
  object {
    var trees : IterRep<X, Y> = ?(#tr t, null);
    public func next() : ?(X, Y) {
      switch (dir, trees) {
      case (_, null) { null };
      case (_, ?(#tr(#leaf), ts))                     { trees := ts; next() };
      case (_, ?(#xy xy, ts))                         { trees := ts; switch (xy.1) { case null next(); case (?y) ?(xy.0, y) } };
      case (#l2r, ?(#tr(#node(_, l, xy, r)), ts))     { trees := ?(#tr l, ?(#xy xy, ?(#tr r, ts))); next() };
      case (#r2l, ?(#tr(#node(_, l, xy, r)), ts))     { trees := ?(#tr r, ?(#xy xy, ?(#tr l, ts))); next() };
      }
    };
  }
};


/*
Triggers compiler Error:
  Fatal error: exception "Assert_failure mo_frontend/coverage.ml:300:4"

public func height<X, Y>(t:Tree<X, Y>) : Nat {
  switch t {
    case (#leaf) 0;
    case (#node(_, _, l, r)) {
           ExtNat.max(height(l), height(r))
         }
  }
};
*/


/*
Triggers compiler error:
  Fatal error: exception "Assert_failure mo_frontend/coverage.ml:300:4"

public func size<X, Y>(t:Tree<X, Y>) : Nat {
  switch t {
    case (#leaf) 0;
    case (#node(_, _, l, r)) {
           size(l) + size(r)
         };
  }
};
*/

/*
 To do: Check invariants for tests:

 isRedBlack =def=

 binarySearchOrder( )
 and
 noRedRed( )
 and
 okBlackHeight( )
*/


func removeRec<X, Y>(x:X, compareTo:(X, X) -> Comp, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  switch t {
  case (#leaf) { (null, #leaf) };
  case (#node(c, l, xy, r)) {
         switch (compareTo(x, xy.0)) {
         case (#lt) {
                let (yo, l2) = removeRec(x, compareTo, l);
                (yo, #node(c, l2, xy, r))
              };
         case (#eq) {
                (xy.1, #node(c, l, (x, null), r))
              };
         case (#gt) {
                let (yo, r2) = removeRec(x, compareTo, r);
                (yo, #node(c, l, xy, r2))
              };
         }
       }
  }
};



func bal<X, Y>(color:Color, lt:Tree<X, Y>, kv:(X, ?Y), rt:Tree<X, Y>) : Tree<X, Y> {
  // thank you, algebraic pattern matching!
  // following notes from [Ravi Chugh](https://www.classes.cs.uchicago.edu/archive/2019/spring/22300-1/lectures/RedBlackTrees/index.html)
  switch (color, lt, kv, rt) {
  case (#B, #node(#R, #node(#R, a, x, b), y, c), z, d) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, #node(#R, a, x, #node(#R, b, y, c)), z, d) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, a, x, #node(#R, #node(#R, b, y, c), z, d)) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, a, x, #node(#R, b, y, #node(#R, c, z, d))) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case _ { #node(color, lt, kv, rt) };
  }
};

func insertRoot<X, Y>(x:X, compareTo:(X, X) -> Comp, y:Y, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  switch (insertRec(x, compareTo, y, t)) {
  case (_, #leaf) { assert false; loop { } };
  case (yo, #node(_, l, xy, r)) { (yo, #node(#B, l, xy, r)) };
  }
};

func insertRec<X, Y>(x:X, compareTo:(X, X) -> Comp, y:Y, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  switch t {
  case (#leaf) { (null, #node(#R, #leaf, (x, ?y), #leaf)) };
  case (#node(c, l, xy, r)) {
         switch (compareTo(x, xy.0)) {
         case (#lt) {
                let (yo, l2) = insertRec(x, compareTo, y, l);
                (yo, bal(c, l2, xy, r))
              };
         case (#eq) {
                (xy.1, #node(c, l, (x, ?y), r))
              };
         case (#gt) {
                let (yo, r2) = insertRec(x, compareTo, y, r);
                (yo, bal(c, l, xy, r2))
              };
         }
       }
  }
};

func findRec<X, Y>(x:X, compareTo:(X, X) -> Comp, t:Tree<X, Y>) : ?Y {
  switch t {
  case (#leaf) { null };
  case (#node(c, l, xy, r)) {
         switch (compareTo(x, xy.0)) {
         case (#lt) { findRec(x, compareTo, l) };
         case (#eq) { xy.1 };
         case (#gt) { findRec(x, compareTo, r) };
         }
       };
  }
};


public module Draw {

public func renderColor(c:Color) : Render.Color = {
  switch c {
  case (#R) { (255, 100, 100) };
  case (#B) { (255, 255, 255) };
  }
};

public func textAttsLabel(c:Color) : Render.TextAtts = {
  zoom=2;
  fgFill=#closed(renderColor(c));
  bgFill=#closed((0,0,0));
  glyphDim={width=5; height=5};
  glyphFlow={
    dir=#right;
    intraPad=1;
    interPad=1
  };
};

public func textAttsNull() : Render.TextAtts = {
  zoom=2;
  fgFill=#closed((255, 100, 100));
  bgFill=#closed((100, 0, 0));
  glyphDim={width=5; height=5};
  glyphFlow={
    dir=#right;
    intraPad=1;
    interPad=1
  };
};

public func textAttsLeaf() : Render.TextAtts = {
  zoom=2;
  fgFill=#closed((100, 255, 100));
  bgFill=#closed((0, 100, 0));
  glyphDim={width=5; height=5};
  glyphFlow={
    dir=#right;
    intraPad=1;
    interPad=1
  };
};

// "child vs parent" as "down vs "up":
public func parentChildFlow() : Render.FlowAtts =
  {
    dir=#down;
    intraPad=2;
    interPad=2;
  };

// "sibling-1 vs sibling-2" as "left vs right":
public func siblingSiblingFlow() : Render.FlowAtts =
  {
    dir=#right;
    intraPad=2;
    interPad=2;
  };

// key-vs-value flow as left-to-right
public func labelFlow() : Render.FlowAtts =
  {
    dir=#right;
    intraPad=2;
    interPad=2;
  };

func drawTreeRec<X, Y>(
  r: Render.Render,
  tree: Tree<X, Y>,
  drawXY: (X, ?Y) -> Render.Elm,
) {
  r.beginFlow(parentChildFlow());
  r.fill(#open((100, 0, 100), 1));
  switch tree {
  case (#node (c, lc, (x, y), rc)) {
         r.beginFlow(labelFlow());
         r.fill(#open(renderColor(c), 1));
         r.elm(drawXY(x, y));
         r.end();
         r.beginFlow(siblingSiblingFlow());
         // to do: Understand why we cannot currently infer these:
         drawTreeRec<X, Y>(r, lc, drawXY);
         drawTreeRec<X, Y>(r, rc, drawXY);
         r.end();
       };
  case (#leaf) {
         r.begin(#none);
         r.text("*", textAttsLeaf());
         r.end();
       };
  };
  r.end()
};

public func drawTree<X, Y>(
  tree: Tree<X, Y>,
  drawXY: (X, ?Y) -> Render.Elm,
) : Render.Elm
{
  let r = Render.Render();
  drawTreeRec(r, tree, drawXY);
  r.getElm()
};

};

public module Test {

  public func run() {
    let sorted =
      [
        (1, "reformer"),
        (2, "helper"),
        (3, "achiever"),
        (4, "individualist"),
        (5, "investigator"),
        (6, "loyalist"),
        (7, "enthusiast"),
        (8, "challenger"),
        (9, "peacemaker"),
      ];

    let unsort =
      [
        (6, "loyalist"),
        (3, "achiever"),
        (9, "peacemaker"),
        (1, "reformer"),
        (4, "individualist"),
        (2, "helper"),
        (8, "challenger"),
        (5, "investigator"),
        (7, "enthusiast"),
      ];

    func compareNats(x:Nat, y:Nat) : Comp =
      if (x < y) #lt else if (x > y) #gt else #eq;

    var t = RBTree<Nat, Text>(compareNats);

    for ((num, lab) in sorted.vals()) {
      Debug.print (Nat.toText num);
      Debug.print lab;
      ignore t.insert(num, lab);
    };

    { var i = 1;
    for ((num, lab) in t.iter()) { 
      assert(num == i);
     i += 1;
    }};

    { var i = 9;
    for ((num, lab) in t.rev()) {
      assert(num == i);
      i -= 1;
    }};

  };
} // module Test

}
