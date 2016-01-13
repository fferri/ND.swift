import Foundation

public class Const : AlgebraicExpr, CustomStringConvertible {
    var value: Int = 0
    
    init(_ v: Int) {
        value = v
    }
    
    public override func eval(s: State) -> Int {
        return value
    }

    static func readConst(ts: TokenStream) -> AlgebraicExpr? {
        if let i = AlgebraicExpr.readIntAtom(ts) {
            return Const(i)
        }
        return nil
    }
    
    public var description: String {
        return "\(value)"
    }
}