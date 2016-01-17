import Foundation

public class Repeat : Program, CustomStringConvertible {
    let body: Program
    
    init(_ body: Program) {
        self.body = body
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        var f = true // first iter will yield Empty
        let g = body.trans(s).generate()
        return anyGenerator{
            if f {
                f = false
                return (Empty(), s)
            }
            if let (p1, s1) = g.next() {
                return (Sequence(p1, self), s1)
            } else {
                return nil
            }
        }
    }
    
    public override func final(s: State) -> Bool {
        return false //XXX: should be true?
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "repeat" else {break parse}
            guard let body = Program.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return Repeat(body)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(repeat \(body))"
    }
}
