import Foundation

public class Head : Expr {
    let l: Expr
    
    init(_ l: Expr) {
        self.l = l
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return transformGenerator(l.eval(s)) {
            x in head(x)
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
