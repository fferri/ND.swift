import Foundation

public class Program {
    func trans(s: State) -> (Program, State)? /* AnyGenerator<(Program, State)> */ {
        return nil
    }
    
    func final(s: State) -> Bool {
        return false
    }
    
    public func exec(s: State) -> State {
        if final(s) {return s}
        let (p1, s1) = trans(s)!
        return p1.exec(s1)
    }
    
    class func parse(ts: TokenStream) -> Program? {
        if let x = Sequence.parse(ts) {return x}
        if let x = Assign.parse(ts) {return x}
        if let x = If.parse(ts) {return x}
        if let x = While.parse(ts) {return x}
        if let x = Print.parse(ts) {return x}
        return nil
    }
}
