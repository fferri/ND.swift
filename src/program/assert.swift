import Foundation

public class Assert : Program, CustomStringConvertible {
    let cond: Expr
    
    init(_ cond: Expr) {
        self.cond = cond
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        if cond.eval(s).asBool {
            return generateOnce{
                return (Empty(), s)
            }
        } else {
            return emptyGenerator()
        }
    }
    
    override public func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "assert" else {break parse}
            guard let cond = Expr.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return Assert(cond)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(assert \(cond))"
    }
}
