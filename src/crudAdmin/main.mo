import Identified "identified";
import Compare "compare";
import ClassParams "classParams";

actor {
  public func testClassParams() {
    let a = ClassParams.Animal(3, func (x:Nat) : Nat { x / 3 });
    a.printStuff()
  };
}
