import Foundation

public class Sequence : Program, CustomStringConvertible {
    let p1, p2: Program
    
    init(_ p1: Program, _ p2: Program) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func trans(s: State) -> (Program, State)? {
        if p1.final(s) {return p2.trans(s)}
        let (p11, s1) = p1.trans(s)!
        return (Sequence(p11, p2), s1)
    }
    
    public override func final(s: State) -> Bool {
        return p1.final(s) && p2.final(s)
    }

    static func readSequence(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let p1 = Program.readProgram(ts) else {return nil}
            guard let p2 = Program.readProgram(ts) else {return nil}
            var p = Sequence(p1, p2)
            while let pn = Program.readProgram(ts) {
                p = Sequence(p, pn)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return p
        }
    }
    
    public var description: String {
        return "(\(p1) \(p2))"
    }
}
