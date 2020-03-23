// 2D rendering abstractions
import Buf "mo:stdlib/buf";
import P "mo:stdlib/prelude";

type Color = (Nat8, Nat8, Nat8);

type Dim = { width: Nat;
             height: Nat };

type Pos = { x:Nat;
             y:Nat };

type Rect = { pos:Pos; 
              dim:Dim };

type Node = { rect: Rect; 
              fill: Fill; 
              children: Elms };

type Elm = { #rect: (Rect, Fill);
             #node: Node };

type Fill = {#open: (Color, Nat);
             #closed: Color;
             #none};

type Elms = [Elm];


/*
public func rect(x_:Nat, y_:Nat, width_:Nat, height_:Nat) : Rect {
  {
    pos= { x = x_;
           y = y_; };
    dim= { width = width_;
           height = height_ };
  }
};

type FrameType = {
  #none;
  #flow(FlowAtts);
};

type Dir2D = {#up; #down; #left; #right};

type FlowAtts = {
  dir: Dir2D;
  intra_pad: Nat;
  inter_pad: Nat;
};

type Frame = {
  typ: FrameType,
  fill: Fill;
  elms: Buf.Buf<Elm>;
};

class Render {
  
  var frame = {
    fill=#none;
    typ=#none;
    elms=Buf.Buf(0);
  };
  
  var stack = Buf.Buf(0);
  
  func begin(typ_:FrameType) {
    let new_frame = {
      fill=#none;
      typ=typ_;
      elms=Buf.Buf(0);
    };
    stack.push(frame);
    frame := new_frame;
  };

  func end() {
    switch stack.pop() {
    case null { P.unreachable() };
    case (?frame_1) {
           let frame_2 = frame;
           frame := frame_1;
           // frame.elms.push( frame_2 )
         };
    }
  };
}
*/
