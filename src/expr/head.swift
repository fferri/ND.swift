import Foundation

public class Head : Expr {
    let l: Expr
    
    init(_ l: Expr) {
        self.l = l
    }
    
    public override func eval(s: State) -> Value {
        switch(l.eval(s)) {
        case let (.List(v)):
            switch(v) {
            case .Nil: fatalError("cannot get head of empty list")
            case let .Node(h, _): return h
            }
        default:
            fatalError("invalid operand \(l) for head")
        }
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "head", minArity: 1, maxArity: 1) else {return nil}
        return Head(o[0])
    }
    
    public override var description: String {
        return "(head \(l))"
    }
}
