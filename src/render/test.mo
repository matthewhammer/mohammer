import P "mo:stdlib/prelude";
import Render "render";
import Animate "animate";
import RBTree "../common/RedBlackTree";

actor {

  public func rbTree() : async RBTree.Tree<Nat, Nat> {
    let t = RBTree.RBTree<Nat, Nat>(
      func(x:Nat,y:Nat) : RBTree.Comp {
        if (x < y) { #lt } else if (x > y) { #gt } else { #eq }
      });
    t.getTree()
  };

  public func _animate() : async Animate.Anim {
    P.xxx()
  };
}
