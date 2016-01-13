import Foundation

public class Var : AlgebraicExpr, CustomStringConvertible {
    var name: String = ""
    
    init(_ n: String) {
        name = n
        super.init()
    }
    
    public override func eval(s: State) -> Int {
        if let v = s[name] {
            return v
        } else {
            fatalError("no such variable: \(name)")
        }
    }

    static func readVar(ts: TokenStream) -> AlgebraicExpr? {
        if let s = AlgebraicExpr.readStringAtom(ts) {
            return Var(s)
        }
        return nil
    }
    
    public var description: String {
        return "\(name)"
    }
}