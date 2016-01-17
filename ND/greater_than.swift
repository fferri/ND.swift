import Foundation

public class GreaterThan : RelationalOp, CustomStringConvertible {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) > b.eval(s)
    }

    override class func parse(ts: TokenStream) -> BoolExpr? {
        guard let (e1, e2) = RelationalOp.parse(ts, op: ">") else {return nil}
        return GreaterThan(e1, e2)
    }
    
    public var description: String {
        return "(> \(a) \(b))"
    }
}
