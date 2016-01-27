import Foundation

public class GreaterThan : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Value {
        return a.eval(s) > b.eval(s)
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: ">", minArity: 2, maxArity: 2) else {return nil}
        return GreaterThan(o[0], o[1])
    }
    
    public override var description: String {
        return "(> \(a) \(b))"
    }
}
