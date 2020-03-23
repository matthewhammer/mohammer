module {

public type Tile = {
  #floor;
  #wall;
  #lock : Id;
  #key : Id;
  #inward : Id;
  #outward : Id;
};
 
public type Id = {
  #nat : Nat;
  #text : Text;
  #tagTup : (Id, [Id]);
};

public type Room = {
  width : Nat;
  height : Nat;
  tiles : [Tile];
};

public type Map = [Room];

public type Dir2D = {#up; #down; #left; #right};

}
