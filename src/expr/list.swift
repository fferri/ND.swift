import Foundation

public class List : Expr {
    let e: [Expr]
    
    init(_ e: [Expr]) {
        self.e = e
    }
    
    public override func eval(s: State) -> Value {
        var r = ListValue.Nil
        for i in 0..<e.count {
            r = ListValue.Node(e[e.count - i - 1].eval(s), r)
        }
        return Value.List(r)
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: nil, minArity: 1) else {return nil}
        return List(o)
    }
    
    public override var description: String {
        return "(\(e.map{String($0)}.joinWithSeparator(" ")))"
    }
}
