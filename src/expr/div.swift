import Foundation

public class Div : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Value {
        return a.eval(s) / b.eval(s)
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "/", minArity: 2) else {return nil}
        var e = Div(o[0], o[1])
        for i in 2..<o.count {
            e = Div(e, o[i])
        }
        return e
    }
    
    public override var description: String {
        return "(/ \(a) \(b))"
    }
}
