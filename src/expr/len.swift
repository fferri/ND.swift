import Foundation

public class Len : Expr {
    let l: Expr
    
    init(_ l: Expr) {
        self.l = l
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return transformGenerator(l.eval(s)) {
            x in len(x)
        }
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "len", minArity: 1, maxArity: 1) else {return nil}
        return Len(o[0])
    }
    
    public override var description: String {
        return "(len \(l))"
    }
}
