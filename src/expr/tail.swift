import Foundation

public class Tail : Expr {
    let l: Expr
    
    init(_ l: Expr) {
        self.l = l
    }
    
    public override func eval(s: State) -> Value {
        return tail(l.eval(s))
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "tail", minArity: 1, maxArity: 1) else {return nil}
        return Tail(o[0])
    }
    
    public override var description: String {
        return "(tail \(l))"
    }
}
