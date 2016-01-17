import Foundation

public class Program {
    func trans(s: State) -> AnyGenerator<(Program, State)> {
        return anyGenerator{
            return nil
        }
    }
    
    func final(s: State) -> Bool {
        return false
    }
    
    public func exec(s: State) -> State? {
        if final(s) {return s}
        let g = trans(s).generate()
        for (p1, s1) in g {
            if let s2 = p1.exec(s1) {
                return s2
            }
        }
        return nil
    }
    
    class func parse(ts: TokenStream) -> Program? {
        if let x = Sequence.parse(ts) {return x}
        if let x = Assign.parse(ts) {return x}
        if let x = If.parse(ts) {return x}
        if let x = While.parse(ts) {return x}
        if let x = Print.parse(ts) {return x}
        if let x = FuncDecl.parse(ts) {return x}
        if let x = FuncCall.parse(ts) {return x}
        return nil
    }
}
