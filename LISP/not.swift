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
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "not" else {return nil}
            guard let e1 = BoolExpr.parse(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return Not(e1)
        }
    }
    
    public var description: String {
        return "(not \(e))"
    }
}
