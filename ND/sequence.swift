import Foundation

public class Sequence : Program, CustomStringConvertible {
    let p1, p2: Program
    
    init(_ p1: Program, _ p2: Program) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        if p1.final(s) {
            let g2 = p2.trans(s)
            return anyGenerator{
                return g2.next()
            }
        }
        let g1 = p1.trans(s)
        return anyGenerator{
            if let (p1, s1) = g1.next() {
                return (Sequence(p1, self.p2), s1)
            } else {
                return nil
            }
        }
    }
    
    public override func final(s: State) -> Bool {
        return p1.final(s) && p2.final(s)
    }

    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let p1 = Program.parse(ts) else {break parse}
            guard let p2 = Program.parse(ts) else {break parse}
            var p = Sequence(p1, p2)
            while let pn = Program.parse(ts) {
                p = Sequence(p, pn)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return p
        }
        ts.pos = oldpos
        return nil
    }

    public var description: String {
        return "(\(p1) \(p2))"
    }
}
