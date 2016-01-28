import Foundation

public class Equal : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return generateTransformedProduct(a.eval(s), b.eval(s)) {
            x, y in x == y
        }
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "=", minArity: 2, maxArity: 2) else {return nil}
        return Equal(o[0], o[1])
    }
    
    public override var description: String {
        return "(= \(a) \(b))"
    }
}
