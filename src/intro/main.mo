import Result "mo:stdlib/result";
import Render "../render/render";
import Array "mo:stdlib/array";
import I "mo:stdlib/iter";

actor {

  var n = 0;

  public func reset() { n := 0 };

  public func getCount() : async Nat { n };
  
  public func incCount() : async Nat { n += 1; n };

  public func getText(t:Text) : async Text {
    "hello " # t # "!"
  };


  func textAtts() : Render.TextAtts = {
    let horz = { dir=#right;
                 interPad=2;
                 intraPad=1;
    };
    {
      zoom=1;
      fgFill=#none;
      bgFill=#none;
      glyphDim={width=5;height=5};
      glyphFlow=horz;
    }
  };
  
  public func drawText(t:Text) : async Result.Result<Render.Elms, Render.Elms> {    
    #ok([#text("Hello, " # t # "!", textAtts())])
  };

  public func drawCount() : async Result.Result<Render.Elms, Render.Elms> {
    
    let rect : Render.Rect = {
      pos={x=0; y=1};
      dim={width=10;height=11}
    };
    
    let fill : Render.Fill = #closed((254,200,255));

    func rectOf(n:Nat) : Render.Rect = {
      pos={x=0; y=1};
      dim={width=10 + n; 
           height=if(n < 5){11 - n} else { 5 }}
    };
    
    func fillOf(n:Nat) : Render.Fill = 
      #closed((254, 
               200 * n / 256, 
               if (n < 5) { 255 - (n * 5) } else { 200 }));
    
    func elmOf(n:Nat) : Render.Elm = 
      #rect(rectOf n, fillOf n);

    #ok(Array.tabulate(n, elmOf))
  };

  public func drawGrid() : async Result.Result<Render.Elms, Render.Elms> {
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
      for (i in I.range(0, n - 1)) {
        r.begin(horz);
        for (j in I.range(0, n - 1)) {
          r.rect(
            { 
              pos={
                x=0; 
                y=0;
              };
              dim={
                width=10 + i; 
                height=10 + j + i;
              }
            },
            #closed(
              (255 - i + j / 256,
               i * j / 256,
               255 - (i + j) * 10 / 256
              )
            )
          );
        };
        r.end();
      };
      r.end();    
      // done rendering, return the elements:
    } else {
      r.text("0", textAtts())
    };
    #ok(r.getElms())
  }

/*
 Rectangle becomes this Candid message (left-hand column gives legend):

 [
   #ok     Variant(IDLField { id: 24860, 
           val: Vec([Variant(
   #rect   IDLField { id: 1269255460, 
           val: Record([
   0       IDLField { id: 0, val: 
           Record([
   #dim    IDLField { id: 4996424, val: Record([
   #height IDLField { id: 38537191, val: Nat(11) }, 
   #width  IDLField { id: 3395466758, val: Nat(10) }]) }, 
   #pos    IDLField { id: 5594516, val: 
           Record([
   #x      IDLField { id: 120, val: Nat(0) }, 
   #y      IDLField { id: 121, val: Nat(1) }]) }]) }, 
   1       IDLField { id: 1, val: Variant(
   #closed IDLField { id: 240232876, val: Record([
           IDLField { id: 0, val: Nat(254) }, 
           IDLField { id: 1, val: Nat(200) }, 
           IDLField { id: 2, val: Nat(255) }]) }) }]) })]) })]"
 */
}


/*
 DRAW GRID

#rect ...460
#node ...690
#pos  ...516
#dim  ...424
#elms ...421

 [Variant(IDLField { id: 24860, val: Vec([
Variant(IDLField { id: 1225394690, val: Record([IDLField { id: 1125441421, val: Vec([
Variant(IDLField { id: 1225394690, val: Record([IDLField { id: 1125441421, val: Vec([
Variant(IDLField { id: 1269255460, val: Record([IDLField { id: 0, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(10) }, IDLField { id: 3395466758, val: Nat(10) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(2) }, IDLField { id: 121, val: Nat(2) }]) }]) }, IDLField { id: 1, val: Variant(IDLField { id: 240232876, val: Record([IDLField { id: 0, val: Nat(0) }, IDLField { id: 1, val: Nat(0) }, IDLField { id: 2, val: Nat(0) }]) }) }]) }), Variant(IDLField { id: 1269255460, val: Record([IDLField { id: 0, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(10) }, IDLField { id: 3395466758, val: Nat(10) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(13) }, IDLField { id: 121, val: Nat(2) }]) }]) }, IDLField { id: 1, val: Variant(IDLField { id: 240232876, val: Record([IDLField { id: 0, val: Nat(0) }, IDLField { id: 1, val: Nat(0) }, IDLField { id: 2, val: Nat(0) }]) }) }]) })]) }, IDLField { id: 1136381571, val: Variant(IDLField { id: 1225396920, val: Null }) }, IDLField { id: 1269255460, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(0) }, IDLField { id: 3395466758, val: Nat(0) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(2) }, IDLField { id: 121, val: Nat(2) }]) }]) }]) }), Variant(IDLField { id: 1225394690, val: Record([IDLField { id: 1125441421, val: Vec([Variant(IDLField { id: 1269255460, val: Record([IDLField { id: 0, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(10) }, IDLField { id: 3395466758, val: Nat(10) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(2) }, IDLField { id: 121, val: Nat(2) }]) }]) }, IDLField { id: 1, val: Variant(IDLField { id: 240232876, val: Record([IDLField { id: 0, val: Nat(1) }, IDLField { id: 1, val: Nat(0) }, IDLField { id: 2, val: Nat(0) }]) }) }]) }), Variant(IDLField { id: 1269255460, val: Record([IDLField { id: 0, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(10) }, IDLField { id: 3395466758, val: Nat(10) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(13) }, IDLField { id: 121, val: Nat(2) }]) }]) }, IDLField { id: 1, val: Variant(IDLField { id: 240232876, val: Record([IDLField { id: 0, val: Nat(1) }, IDLField { id: 1, val: Nat(0) }, IDLField { id: 2, val: Nat(0) }]) }) }]) })]) }, IDLField { id: 1136381571, val: Variant(IDLField { id: 1225396920, val: Null }) }, IDLField { id: 1269255460, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(0) }, IDLField { id: 3395466758, val: Nat(0) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(2) }, IDLField { id: 121, val: Nat(3) }]) }]) }]) })]) }, IDLField { id: 1136381571, val: Variant(IDLField { id: 1225396920, val: Null }) }, IDLField { id: 1269255460, val: Record([IDLField { id: 4996424, val: Record([IDLField { id: 38537191, val: Nat(0) }, IDLField { id: 3395466758, val: Nat(0) }]) }, IDLField { id: 5594516, val: Record([IDLField { id: 120, val: Nat(0) }, IDLField { id: 121, val: Nat(0) }]) }]) }]) })]) })]

*/
