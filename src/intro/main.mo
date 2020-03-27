import Result "mo:stdlib/result";
import Render "../render/render";
import Array "mo:stdlib/array";
import I "mo:stdlib/iter";

actor {

  var n = 0;

  public func reset() { n := 0 };

  public func get() : async Nat { n };
  
  public func inc() : async Nat { n += 1; n };

  public func double() : async Nat { n *= 2; n };

  public func drawCount() : async Result.Result<Render.Out, Render.Out> {

    func getRect(n:Nat) : Render.Rect = {
      pos={x=0; y=0} : Render.Pos; // position ignored, we are using a flow layout
      dim={width=10 + n * 2;
           height=if(n < 10){11 - n} else { 5 }}
    };
    
    func getFill(n:Nat) : Render.Fill = 
      #closed((254,
               200 * n / 256, 
               if (n < 10) { 255 - (n * 5) } else { 200 }));
    
    let r = Render.Render();
    r.begin(#flow{dir=#right;interPad=5;intraPad=5;});
    if (n > 0) {
      for (i in I.range(0, n - 1)) {
        r.rect(getRect i, getFill i)
      };
    } else {
      r.text("0", textAtts())
    };
    r.end();
    #ok(#draw(r.getElm()))
  };

  public func drawGrid() : async Result.Result<Render.Out, Render.Out> {
    let horz : Render.FrameType = 
      #flow{ dir=#right;
             interPad=5;
             intraPad=5;
      };

    let vert : Render.FrameType = 
      #flow{ dir=#down;
             interPad=5;
             intraPad=5;
      };

    // begin rendering the grid:
    let r = Render.Render();
    if (n > 0) {
      r.begin(vert);
      r.fill(#open((255, 0, 255), 1));
      for (i in I.range(0, n - 1)) {
        r.begin(horz);
        r.fill(#open((255, 255, 0), 1));
        for (j in I.range(0, n - 1)) {
          r.rect(
            { 
              pos={
                x=0; 
                y=0;
              };
              dim={
                width=10 + i; 
                height=10 + j + (i * 2);
              }
            },
            // checkerboard colors:
            if (i % 2 == 0 and j % 2 == 1 or 
                i % 2 == 1 and j % 2 == 0)
             {
                 #closed(
                   (255 - i + j / 256,
                    i * j / 256,
                    255 - (i + j) * 10 / 256
                   )
                 )                 
             } else {
                 #closed(
                   (255 - i * j / 256,                    
                    255 - (i + j) * 10 / 256,
                    i * j / 256
                   )
                 )
             }
          );
        };
        r.end();
      };
      r.end();    
      // done rendering, return the elements:
    } else {
      r.text("0", textAtts())
    };
    #ok(#draw(r.getElm()))
  };

  func textAtts() : Render.TextAtts = {
    zoom=1;
    fgFill=#none;
    bgFill=#none;
    glyphDim={width=5;height=5};
    glyphFlow={
      dir=#right;
      interPad=2;
      intraPad=1;
    }
  };
  
  public func getText(t:Text) : async Text {
    "hello " # t # "!"
  };
      
  public func drawText(t:Text) : async Result.Result<Render.Out, Render.Out> {    
    #ok(#draw(#text("Hello, " # t # "!", textAtts())))
  };

}
