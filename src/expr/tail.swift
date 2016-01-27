import Foundation

public class Tail : Expr {
    let l: Expr
    
    init(_ l: Expr) {
        self.l = l
    }
    
    public override func eval(s: State) -> Value {
        switch(l.eval(s)) {
        case let (.List(v)):
            switch(v) {
            case .Nil: fatalError("cannot get tail of empty list")
            case let .Node(_, t): return .List(t)
            }
        default:
            fatalError("invalid operand \(l) for tail")
        }
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "tail", minArity: 1, maxArity: 1) else {return nil}
        return Tail(o[0])
    }
    
    public override var description: String {
        return "(tail \(l))"
    }
}
