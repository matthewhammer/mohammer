import Array "mo:stdlib/array";
import Render "../render/render";
import RBT "../common/RedBlackTree";
import Nat "mo:stdlib/nat";
import Debug "mo:stdlib/debug";

actor {

  func compareNats(x:Nat, y:Nat) : RBT.Comp =
    if (x < y) #lt else if (x > y) #gt else #eq;

  var t = RBT.RBTree<Nat, Text>(compareNats);

  public func insert(x:Nat, y:Text) : async ?Text {
    t.insert(x, y)
  };

  public func remove(x:Nat) : async ?Text {
    t.remove(x)
  };

  func drawLabel(x:Nat, y:?Text) : Render.Elm {
    let ta = RBT.Draw.textAttsLabel(#B);
    let taNull = RBT.Draw.textAttsNull();
    let flowAtts = {
      dir=#right;
      intraPad=2;
      interPad=1
    };
    let r = Render.Render();
    r.beginFlow(flowAtts);
    r.text("(", ta);
    r.text(Nat.toText(x), ta);
    r.text(",", ta);
    switch y {
    case null { r.text("null", taNull); };
    case (?y) { r.text(y, ta); };
    };
    r.text(")", ta);
    r.end();
    let elm = r.getElm();
    elm
  };

  public func test() : async () {
    RBT.Test.run();
  };

  public func enneagram() : async {#ok:Render.Out} {
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

    var t2 = RBT.RBTree<Nat, Text>(compareNats);

    for ((num, lab) in sorted.vals()) {
      Debug.print (Nat.toText num);
      Debug.print lab;
      ignore t.insert(num, lab);
      ignore t2.insert(num, lab);
    };

    Debug.print "## sorted order:";
    for ((num, lab) in t2.iter()) {
      Debug.print (Nat.toText num);
      Debug.print lab;
    };

    Debug.print "## reverse order:";
    for ((num, lab) in t2.rev()) {
      Debug.print (Nat.toText num);
      Debug.print lab;
    };

    #ok(
      #redraw(
        [
          ("tree",
           RBT.Draw.drawTree(t.getTree(), drawLabel))
        ]
      )
    )
  };

  public query func redrawTree() : async {#ok:Render.Out} {
    #ok(
      #redraw(
        [
          ("tree",
           RBT.Draw.drawTree(t.getTree(), drawLabel))
        ]
      )
    )
  };

};
