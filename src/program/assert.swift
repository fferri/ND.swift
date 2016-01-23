import Foundation

public class Assert : Program, CustomStringConvertible {
    let cond: BoolExpr
    
    init(_ cond: BoolExpr) {
        self.cond = cond
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        if cond.eval(s) {
            var r: (Program, State)? = (Empty(), s)
            return anyGenerator{
                let r1 = r
                r = nil
                return r1
            }
        } else {
            return anyGenerator{
                return nil
            }
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
            guard let cond = BoolExpr.parse(ts) else {break parse}
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