import Foundation

public class Equal : BoolExpr, CustomStringConvertible {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) == b.eval(s)
    }

    static func readEqual(ts: TokenStream) -> BoolExpr? {
        guard let (e1, e2) = BoolExpr.readRelOp(ts, op: "=") else {return nil}
        return Equal(e1, e2)
    }
    
    public var description: String {
        return "(= \(a) \(b))"
    }
}
