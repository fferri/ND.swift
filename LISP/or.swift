import Foundation

public class Or : BoolOp, CustomStringConvertible {
    let a, b: BoolExpr
    
    init(_ a: BoolExpr, _ b: BoolExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) || b.eval(s)
    }

    override class func parse(ts: TokenStream) -> BoolExpr? {
        guard let o = BoolOp.parse(ts, op: "or") else {return nil}
        var e = Or(o[0], o[1])
        for i in 2..<o.count {
            e = Or(e, o[i])
        }
        return e
    }
    
    public var description: String {
        return "(or \(a) \(b))"
    }
}
