import Foundation

public class Add : AlgebraicExpr, CustomStringConvertible {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) + b.eval(s)
    }

    static func readAdd(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicExpr.readOp(ts, op: "+") else {return nil}
        var e = Add(o[0], o[1])
        for i in 2..<o.count {
            e = Add(e, o[i])
        }
        return e
    }
    
    public var description: String {
        return "(+ \(a) \(b))"
    }
}