import List "mo:stdlib/list";
import Result "mo:stdlib/result";
import Render "../render/render";
import Types "types";

module {

  type State = Types.State;
  type TextAtts = Render.TextAtts;

  // Flow atts --------------------------------------------------------

  let legendPad : Render.FlowAtts = {
    dir=#right;
    interPad=20;
    intraPad=20;
  };

  let textHorz : Render.FlowAtts = {
    dir=#right;
    interPad=1;
    intraPad=1;
  };

  let horz : Render.FlowAtts = {
    dir=#right;
    interPad=1;
    intraPad=1;
  };

  let vert : Render.FlowAtts = {
    dir=#down;
    interPad=1;
    intraPad=1;
  };

  // Text atts --------------------------------------------------------

  func tileAtts(fg:Render.Fill, bg:Render.Fill) : TextAtts = {
    {
      zoom=4;
      fgFill=fg;
      bgFill=bg;
      glyphDim={width=5;height=5};
      glyphFlow=horz;
    }
  };

  func taLegend(fg:Render.Fill) : TextAtts = {
    {
      zoom=2;
      fgFill=fg;
      bgFill=#closed((0, 0, 0));
      glyphDim={width=5;height=5};
      glyphFlow=textHorz;
    }
  };

  func taLegendText() : Render.TextAtts =
    taLegend(#closed((200, 200, 200)));

  // Fill names --------------------------------------------------------

  func bgFill() : Render.Fill = #closed((50, 10, 50));
  func taVoid() : TextAtts = tileAtts(#none, #none);
  func taPlayer() : TextAtts = tileAtts(#closed((255, 255, 255)), bgFill());
  func taStart() : TextAtts = tileAtts(#closed((255, 100, 255)), bgFill());
  func taGoal() : TextAtts = tileAtts(#closed((255, 240, 255)), bgFill());
  func taWall() : TextAtts = tileAtts(#closed((200, 100, 200)), bgFill());
  func taFloor() : TextAtts = tileAtts(#closed((200, 100, 200)), bgFill());
  func taLock() : TextAtts = tileAtts(#closed((200, 200, 100)), bgFill());
  func taKey() : TextAtts = tileAtts(#closed((255, 255, 100)), bgFill());

  // --------------------------------------------------------

  public func drawState(st:State) : Render.Elm {

    let r = Render.Render();
    let room_tiles = st.maze.rooms[st.pos.room].tiles;

    r.begin(#flow(horz)); // Display begin

    r.begin(#flow(vert)); // Legend begin
    r.begin(#flow(vert));
    //r.rect({pos={x=0;y=0};dim={width=150;height=10}}, #none);
    r.begin(#flow(horz));
    r.begin(#flow(vert));
    r.text("(", taLegendText());
    r.end();
    r.begin(#flow(vert));
    r.text(debug_show st.pos.tile.1, taLegendText());
    r.end();
    r.begin(#flow(vert));
    r.text(",", taLegendText());
    r.end();
    r.begin(#flow(vert));
    r.text(debug_show st.pos.tile.0, taLegendText());
    r.end();
    r.begin(#flow(vert));
    r.text(")", taLegendText());
    r.end();
    r.end();

    r.begin(#flow(vert)); // Keys begin
    //r.rect({pos={x=0;y=0};dim={width=150;height=10}}, #none);
    r.text("keys:", taLegendText());
    r.end();
    r.begin(#flow(horz));
    switch (st.keys) {
      case null { r.text("none", taLegendText()) };
      case (?_) {
             List.iter<Types.Id>(st.keys,
               func (_:Types.Id) {
                 r.begin(#flow(vert));
                 r.text("ķ", taLegend(#closed((255, 255, 100))));
                 r.end();
               })
           };
    };
    r.end();
    r.end(); // Keys end
    r.end(); // Legend end

    r.begin(#flow(vert)); // Map begin
    var i = 0;
    for (row in room_tiles.vals()) {
      var j = 0;
      r.begin(#flow(horz));
      for (tile in row.vals()) {
        r.begin(#flow(horz));
        if (j == st.pos.tile.0
        and i == st.pos.tile.1) {
          r.text("☺", taPlayer())
        } else {
          switch tile {
          case (#void) { r.text(" ", taVoid()) };
          case (#start) { r.text("◊", taStart()) };
          case (#goal) { r.text("⇲", taGoal()) };
          case (#floor) { r.text(" ", taFloor()) };
          case (#wall) { r.text("█", taWall()) };
          case (#lock(_)) { r.text("ļ", taLock()) };
          case (#key(_)) { r.text("ķ", taKey()) };
          case (#inward(_)) { r.text("i", taWall()) };
          case (#outward(_)) { r.text("o", taWall()) };
          };
        };
        r.end();
        j += 1;
      };
      r.end();
      i += 1;
    };
    r.end(); // Map end
    r.end(); // Display end
    r.getElm()
  };

}
