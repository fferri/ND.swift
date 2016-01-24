import Foundation

public class While : Program, CustomStringConvertible {
    let cond: Expr
    let body: Program
    
    init(_ cond: Expr, _ body: Program) {
        self.cond = cond
        self.body = body
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        if cond.eval(s).asBool {
            let g = body.trans(s).generate()
            return anyGenerator{
                if let (p1, s1) = g.next() {
                    return (Sequence(p1, self), s1)
                } else {
                    return nil
                }
            }
        } else {
            return generateOnce{
                return (Empty(), s)
            }
        }
    }
    
    public override func final(s: State) -> Bool {
        return !cond.eval(s).asBool || body.final(s)
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "while" else {break parse}
            guard let cond = Expr.parse(ts) else {break parse}
            guard let body = Program.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return While(cond, body)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(while \(cond) \(body))"
    }
}
