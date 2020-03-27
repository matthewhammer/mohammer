import Array "mo:stdlib/array";

module {

  public type Id = Nat;

  public type Identified = {
    getId : () -> Id;
  };


  module Examples20200326 {

    // Two examples show the (one line of) common code
    // that implements the Identified interface for 
    // two concrete classes, SoupCan and FlareGun:
    
    public class SoupCan(id:Id) = {
      public func getId() : Id = id;
      public func consume() {
        assert false
      };
    };
    
    public class FlareGun(id:Id) = {
      public func getId() : Id = id;
      public func fire() {
        assert false
      };     
    };

    func _check_SoupCan_isSubTypeOfIdentified(_sc:SoupCan) : Identified = _sc;
    func _check_FlareGun_isSubTypeOfIdentified(_fg:FlareGun) : Identified = _fg;    

    func makeArrays(fg:FlareGun, sc:SoupCan) : ([Identified], [Id]) {
      let things : [Identified] = [fg, sc];
      let thingIds = Array.map<Identified, Id>(
        func (t:Identified) {
          t.getId()
        }, things);
      (things, thingIds)
    };
    
    // Aside:
    // We may be _tempted_ to refactor and share code.
    // However,
    // If we try abstract this "common" code,
    // there does not seem to be a benefit in Motoko:

    public class IdObj(id:Id) = {
      public func getId() : Id = id;
    };
    
    public class EnterpriseSoupCan(id:IdObj) = {
      public func getId() : Id = id.getId();
    };

    // Summary: We need to re-define getId() no matter what, since
    // there is no inheritance/overloading mechanism that would expose
    // `getId` from the `id` field on behalf of `EnterpriseSoupCan`;
    // rather, that class needs to define its own interface, where it
    // can use its private components, as usual.

  };

}
