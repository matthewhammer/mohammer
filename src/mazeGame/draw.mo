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

  func taTitleText() : Render.TextAtts =
    taLegend(#closed((255, 200, 255)));

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

    r.begin(#flow(vert)); // Display begin
    r.fill(#open((200, 255, 200), 1));

    // Title line:
    if (st.won) {
      r.begin(#flow(horz));
      r.text("MazeGame: Game over, You won!!", taTitleText());
      r.end();
    } else {
      r.begin(#flow(horz));
      r.text("MazeGame in Motoko!", taTitleText());
      r.end();
    };

    r.begin(#flow(horz)); // Inner-display begin

    r.begin(#flow(vert)); // Legend begin

    r.begin(#flow(vert));
    r.begin(#flow(horz));
    r.text("room:", taLegendText());
    r.end();
    r.begin(#flow(horz));
    r.begin(#flow(vert));
    r.text(debug_show st.pos.room, taLegendText());
    r.end();
    r.end();

    r.begin(#flow(horz));
    r.text("tile:", taLegendText());
    r.end();
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
    r.end(); // Inner-display end
    r.end(); // Display end
    r.getElm()
  };

}
