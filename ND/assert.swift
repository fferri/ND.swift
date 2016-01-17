import Foundation

public class Assert : Program, CustomStringConvertible {
    let cond: BoolExpr
    
    init(_ cond: BoolExpr) {
        self.cond = cond
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        if cond.eval(s) {
            return anyGenerator{
                return (Empty(), s)
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
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "assert" else {return abort()}
        guard let cond = BoolExpr.parse(ts) else {return abort()}
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return Assert(cond)
    }
    
    public var description: String {
        return "(assert \(cond))"
    }
}
