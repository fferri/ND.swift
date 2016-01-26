import Foundation

public class Cons : Expr {
    let h: Expr
    let t: Expr
    
    init(_ h: Expr, _ t: Expr) {
        self.h = h
        self.t = t
    }
    
    public override func eval(s: State) -> Value {
        switch(t.eval(s)) {
        case let (.List(v)):
            return .List(.Node(h.eval(s), v))
        default:
            fatalError("invalid 2nd operand \(t) for cons")
        }
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "cons", minArity: 2, maxArity: 2) else {return nil}
        return Cons(o[0], o[1])
    }
    
    public override var description: String {
        return "(cons \(h) \(t))"
    }
}
