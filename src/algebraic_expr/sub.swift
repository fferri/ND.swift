import Foundation

public class Sub : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) - b.eval(s)
    }

    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicOp.parse(ts, op: "-") else {return nil}
        var e = Sub(o[0], o[1])
        for i in 2..<o.count {
            e = Sub(e, o[i])
        }
        return e
    }
    
    public override var description: String {
        return "(- \(a) \(b))"
    }
}