import Foundation

public class List : Expr {
    let e: [Expr]
    
    init(_ e: [Expr]) {
        self.e = e
    }
    
    public override func eval(s: State) -> Value {
        return Value.List(ListValue.fromArray(e.map{$0.eval(s)}))
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: nil) else {return nil}
        return List(o)
    }
    
    public override var description: String {
        return "(\(e.map{String($0)}.joinWithSeparator(" ")))"
    }
}
