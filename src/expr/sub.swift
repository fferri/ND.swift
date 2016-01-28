import Foundation

public class Sub : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return generateTransformedProduct(a.eval(s), b.eval(s)) {
            x, y in x - y
        }
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "-", minArity: 2) else {return nil}
        var e = Sub(o[0], o[1])
        for i in 2..<o.count {
            e = Sub(e, o[i])
        }
        return e
    }
    
    public override var description: String {
        return "(- \(a) \(b))"
    }
}
