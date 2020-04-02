/**

 ## "Mo-VM"

 A _mobile_ virtual machine for Motoko applications
 that communicate dynamic behavior "over the wire".

 To accomodate mobility, the VM's structure is defined by
 (very simple) Motoko types
 that each map to a corresponding Candid type.

 For now,
 we focus on dynamic behavior from animations,
 and simple programs that produce streams of render elements.
 The VM behavior is intentionally simple and limited.

 ### Incremental updates:

 To keep a remote animation stream "live",
 a Motoko backend canister service
 re-produces the VM periodically for the client.
 (eventually, it updates
 a remote one incrementally,
 via "asynchronous incremental updates", a la Adapton).

*/
import Render "render";
import P "mo:stdlib/prelude";

module {

  public type Name = {
    #text: Text;
    #nat: Nat;
  };

  public type Val = {    
    #vaar : Name;
    #thunk : (Env, Exp);
    #nat : Nat;
    #text : Text;
    #bool : Bool;
    #vec : [Val];
    #record : FieldsVal;
    #variant : FieldVal;
    
    // Domain-specific: Rendering elements:
    #elm : Render.Elm;
  };

  public type FieldVal = {
    name: Name;
    val: Val;
  };

  public type FieldsVal = [FieldVal];

  public type Exp = {
    #get : Name;
    #set : (Name, Val);
    #app : (Exp, Val);
    #lam : (Name, Exp);
    #ret : Val;
    #leet : (Name, Exp, Exp);
    #coProd : FieldsExp;
    #proj : (Name, Exp);
    #fix : (Name, Exp);
    #primOp : (PrimOp, [Val]);
  };

  public type PrimOp = {
    #add;
    #sub;
    #mul;
    #div;
    
    #noot;
    #oor;
    #aand;
    
    #eq;
    #lt;
    #gt;
    #notEq;
    #ltEq;
    #gtEq;
  };

  public type FieldExp = {
    name: Name;
    exp: Exp;
  };

  public type FieldsExp = [FieldExp];

  public type Frame = {
    vaar: Name;
    exp: Exp;
  };

  public type Store = FieldsVal;
  
  public type Env = FieldsVal;

  public type State = {
    stack: [Frame];
    store: Store;
    cont: Exp;
  };

  public type Result<Ok,Err> = {#ok : Ok; #err : Err};

  public type ValTag = {
    #thunk;
    #nat;
    #text;
    #bool;
    #vec;
    #record;
    #variant;
    #elm;
  };

  public type StepError = {
    #stuck : { expected: ValTag; found: ValTag };
  };

  public func step(s:State) : Result<State, StepError> {
    switch (s.cont) {
      case _ { P.xxx() };
    }
  };

  public type EvalError = {
    #step : StepError;
  };
  
  public func eval(s:State) : Result<State, EvalError> {
    P.xxx()
  };
}





