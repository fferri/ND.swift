import Foundation

public class List : Expr {
    let e: [Expr]
    
    init(_ e: [Expr]) {
        self.e = e
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        if e.isEmpty {
            return generateOnce{Value.List(ListValue.Nil)}
        }
        return transformGenerator(generatorProduct(e.map{ei in ei.eval(s)})) {
            x in Value.List(ListValue.fromArray(x))
        }
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: nil) else {return nil}
        return List(o)
    }
    
    public override var description: String {
        return "(\(e.map{String($0)}.joinWithSeparator(" ")))"
    }
}
