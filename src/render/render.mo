// 2D rendering abstractions
import Buf "mo:stdlib/buf";
import List "mo:stdlib/list";
import P "mo:stdlib/prelude";

import Stack "../common/stack";

module {

  public type Color = (Nat8, Nat8, Nat8);
  
  public type Dim = { width: Nat;
                      height: Nat };
  
  public type Pos = { x:Nat;
                      y:Nat };
  
  public type Rect = { pos:Pos; 
                       dim:Dim };
  
  public type Node = { rect: Rect; 
                       fill: Fill; 
                       elms: Elms };
  
  public type Elm = { #rect: (Rect, Fill);
                      #text: (Text, TextAtts);
                      #node: Node };
  
  public type Fill = {#open: (Color, Nat);
                      #closed: Color;
                      #none};
  
  public type Elms = [Elm];

  public type TextAtts = {
    zoom: Nat;
    fgFill: Fill;
    bgFill: Fill;
    glyphDim: Dim;
    glyphFlow: FlowAtts;
  };
  
  public type FlowAtts = {
    dir: Dir2D;
    intraPad: Nat;
    interPad: Nat;
  };  

  public type Dir2D = {#up; #down; #left; #right};

  // - - - - - - - - - - - - - - 
  
  public func rect(x_:Nat, y_:Nat, width_:Nat, height_:Nat) : Rect {
    {
      pos= { x = x_;
             y = y_; };
      dim= { width = width_;
             height = height_ };
    }
  };

  public type FrameType = {
    #none;
    #flow : FlowAtts;
  };

  type Frame = {
    typ: FrameType;
    var fill: Fill;
    elms: Buf.Buf<Elm>;
  };

  // composable operations
  public class Render() {
    
    var frame = {
      var fill=(#none : Fill);
      typ=#none;
      elms=Buf.Buf<Elm>(0);
    } : Frame;
    
    var stack = Stack.Stack<Frame>();
    
    public func begin(typ_:FrameType) {
      let new_frame : Frame = {
        var fill=(#none : Fill);
        typ=typ_;
        elms=Buf.Buf<Elm>(0);
      };
      stack.push(frame);
      frame := new_frame;
    };

    public func fill(f:Fill) {
      frame.fill := f;
    };

    public func nest(r: Render) {
      for (e in r.getElms().vals()) {
        frame.elms.add(e)
      }
    };
    
    public func rect(r:Rect, f:Fill) {
      frame.elms.add(#rect(r, f))
    };

    public func text(t:Text, ta:TextAtts) {
      frame.elms.add(#text(t, ta))
    };

    public func end() {
      switch (stack.pop()) {
      case null { P.unreachable() };
      case (?frame_1) {
             let frame_2 = frame;
             frame := frame_1;
             let elm = elmOfFrame(frame_2);
             frame.elms.add(elm)
           };
      }
    };

    public func getElms() : Elms {
      assert(stack.isEmpty());
      frame.elms.toArray()
    }
  };

  func dimOfElm(elm:Elm) : Dim {
    switch elm {
      case (#node(n)) { n.rect.dim };
      case (#rect(r,_)) r.dim;
      case (#text(t,ta)) { dimOfText(t, ta) };
    }
  };

  func dimOfText(t:Text, ta:TextAtts) : Dim {
    let r = {pos={x=0;y=0}; dim=ta.glyphDim};
    let rr = #rect(r, #none);
    let rs = Buf.Buf<Elm>(0);
    for (_ in t.chars()) {
      rs.add(rr)
    };
    let dim = dimOfFlow(rs.toArray(), ta.glyphFlow);
    dim                              
  };

  func dimOfFlow(elms:Elms, flow:FlowAtts) : Dim {
    // todo
    {width=0; height=0}
  };

  func dimOfFrame(frame:Frame) : Dim {
    // todo
    {width=0; height=0}
  };

  func boundingRectOfElm(elm:Elm) : Rect {
    // todo
    {pos={x=0; y=0}; dim={width=0; height=0}}
  };

  func boundingRectOfElms(elms:Elms) : Rect {
    // todo
    {pos={x=0; y=0}; dim={width=0; height=0}}
  };

  func repositionRect(r:Rect, _pos:Pos) : Rect {
    { pos=_pos; dim=r.dim }
  };

  func repositionElm(elm:Elm, pos:Pos) : Elm {
    switch elm {
      case (#rect(r, f)) { 
             #rect(repositionRect(r, pos), f)
           };
      case (#node(n)) {
             #node{ 
               rect= repositionRect(n.rect, pos);
               fill= n.fill;
               elms= n.elms;
             }
           };
      case (#text(t,ta)) { #text(t, ta) };
    }
  };

  func repositionFrameElms(frame: Frame) : (Elms, Rect) {
    let frameDim = dimOfFrame(frame);
    var elmsOut = Buf.Buf<Elm>(0);
    var posOut = {x=0; y=0};
    switch (frame.typ) {
      case (#none) {
             elmsOut := frame.elms;
             let rect = boundingRectOfElms(frame.elms.toArray());
             posOut := rect.pos
           };
      case (#flow(flow)) {
             let p = flow.interPad;
             var nextPos = switch (flow.dir) {
               case (#right) { x=p; y=p };
               case (#down) { x=p; y=p };
               case (#left) { x=p + frameDim.width;
                              y=p };
               case (#up) { x=p;
                            y=p + frameDim.height; }
             };
             for (elm in frame.elms.iter()) {
               elmsOut.add(repositionElm(elm, nextPos));
               let dim = dimOfElm(elm);
               let p = flow.intraPad;
               nextPos := switch (flow.dir) {
               case (#right) { 
                      {x=nextPos.x + dim.width + p;
                       y=nextPos.y } 
                    };                 
               case (#down) { 
                      {x=nextPos.x;
                       y=nextPos.y + dim.height + p} 
                    };
               case (#left) { 
                      {x=nextPos.x - (dim.width + p);
                       y=nextPos.y;} 
                    };
               case (#up) { 
                      {x=nextPos.x;
                       y=nextPos.y - (dim.height + p)} 
                    };
               }
           }
           };
    };
    ( elmsOut.toArray(), {pos=posOut; dim=frameDim} )
  };

  func elmOfFrame(frame:Frame) : Elm {
    let (elms_, rect_) = repositionFrameElms(frame);
    #node{ rect= rect_;
           fill= frame.fill;
           elms= elms_;
    }
  };
  
}
