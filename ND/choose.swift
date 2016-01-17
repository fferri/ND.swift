import Foundation

public class Choose : Program, CustomStringConvertible {
    let p1, p2: Program
    
    init(_ p1: Program, _ p2: Program) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        let s1 = s
        let g1 = p1.trans(s1)
        let g2 = p2.trans(s1)
        return anyGenerator{
            return g1.next() ?? g2.next()
        }
    }
    
    public override func final(s: State) -> Bool {
        //XXX: return p1.final(s) || p2.final(s) ??? doesn't look correct
        return p1.final(s) && p2.final(s)
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "choose" else {break parse}
            guard let p1 = Program.parse(ts) else {break parse}
            guard let p2 = Program.parse(ts) else {break parse}
            var p = Choose(p1, p2)
            while let pn = Program.parse(ts) {
                p = Choose(p, pn)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return p
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(choose \(p1) \(p2))"
    }
}
