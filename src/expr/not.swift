import Foundation

public class Not : Expr {
    let e: Expr
    
    init(_ e: Expr) {
        self.e = e
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return transformGenerator(e.eval(s)) {
            x in !x
        }
    }

    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "not", minArity: 1, maxArity: 1) else {return nil}
        return Not(o[0])
    }
    
    public override var description: String {
        return "(not \(e))"
    }
}
