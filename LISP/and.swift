import Foundation

public class And : BoolExpr, CustomStringConvertible {
    let a, b: BoolExpr
    
    init(_ a: BoolExpr, _ b: BoolExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) && b.eval(s)
    }

    static func readAnd(ts: TokenStream) -> BoolExpr? {
        guard let o = BoolExpr.readOp(ts, op: "and") else {return nil}
        var e = And(o[0], o[1])
        for i in 2..<o.count {
            e = And(e, o[i])
        }
        return e
    }
    
    public var description: String {
        return "(and \(a) \(b))"
    }
}
