import Foundation

public class ChooseExpr : Expr {
    let args: [Expr]
    
    init(_ args: [Expr]) {
        if args.isEmpty {fatalError("choose requires at least one expr")}
        self.args = args
    }
    
    public override func eval(s: State) -> AnyGenerator<Value> {
        return chainGenerators(args.map{ei in ei.eval(s)})
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        guard let o = NAryOperator.parse(ts, op: "choose", minArity: 1) else {return nil}
        return ChooseExpr(o)
    }
    
    public override var description: String {
        return "(choose \(args.map{String($0)}.joinWithSeparator(" ")))"
    }
}
