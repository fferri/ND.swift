import Foundation

public class Or : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Value {
        switch(a.eval(s), b.eval(s)) {
        case let (.Boolean(av), .Boolean(bv)):
            return .Boolean(av || bv)
        default:
            fatalError("invalid operands \(a), \(b) for or")
        }
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "or", minArity: 2) else {return nil}
        var e = Or(o[0], o[1])
        for i in 2..<o.count {
            e = Or(e, o[i])
        }
        return e
    }
    
    public override var description: String {
        return "(or \(a) \(b))"
    }
}
