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
    
    static func readProgram(ts: TokenStream) -> Program? {
        if let x = Sequence.readSequence(ts) {return x}
        if let x = Assign.readAssign(ts) {return x}
        if let x = If.readIf(ts) {return x}
        if let x = While.readWhile(ts) {return x}
        return nil
    }
}
