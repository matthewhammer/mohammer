import Array "mo:stdlib/array";
import Render "../render/render";
import RBT "../common/RedBlackTree";
import Nat "mo:stdlib/nat";

actor {
      
  func compareNats(x:Nat, y:Nat) : RBT.Comp = 
    if (x < y) #lt else if (y > x) #gt else #eq;

  var t = RBT.RBTree<Nat, Text>(compareNats);

  public func insert(x:Nat, y:Text) : async ?Text {
    t.insert(x, y)
  };

  public query func redrawTree() : async {#ok:Render.Out} {
    let ta = RBT.Draw.textAtts(#B);
    func drawNatText(x:Nat, y:Text) : Render.Elm {
      let r = Render.Render();
      r.beginFlow({dir=#right;
                   intraPad=2;
                   interPad=1});
      r.text(Nat.toText(x), ta);
      r.text(":", ta);
      r.text(y, ta);
      r.end();
      r.getElm()
    };
    #ok(
      #redraw(
        [
          ("tree",
           RBT.Draw.drawTree(t.getTree(), drawNatText))
        ]
      )
    )
  };
  
};
