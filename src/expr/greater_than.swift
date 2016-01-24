import Foundation

public class GreaterThan : Expr {
    let a, b: Expr
    
    init(_ a: Expr, _ b: Expr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Value {
        switch(a.eval(s), b.eval(s)) {
        case let (.Integer(av), .Integer(bv)):
            return .Boolean(av > bv)
        case let (.Floating(av), .Floating(bv)):
            return .Boolean(av > bv)
        case let (.Floating(av), .Integer(bv)):
            return .Boolean(av > Double(bv))
        case let (.Integer(av), .Floating(bv)):
            return .Boolean(Double(av) > bv)
        case let (.Str(av), .Str(bv)):
            return .Boolean(av > bv)
        default:
            fatalError("invalid operands \(a), \(b) for >")
        }
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: ">", minArity: 2, maxArity: 2) else {return nil}
        return GreaterThan(o[0], o[1])
    }
    
    public override var description: String {
        return "(> \(a) \(b))"
    }
}
