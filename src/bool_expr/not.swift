import Foundation

public class Not : BoolExpr, CustomStringConvertible {
    let e: BoolExpr
    
    init(_ e: BoolExpr) {
        self.e = e
    }
    
    public override func eval(s: State) -> Bool {
        return !e.eval(s)
    }

    override class func parse(ts: TokenStream) -> BoolExpr? {
        let oldpos = ts.pos
        let abort = {() -> BoolExpr? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "not" else {return abort()}
        guard let e1 = BoolExpr.parse(ts) else {return abort()}
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return Not(e1)
    }
    
    public var description: String {
        return "(not \(e))"
    }
}
