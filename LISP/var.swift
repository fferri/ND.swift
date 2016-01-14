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

    class func readStringAtom(ts: TokenStream) -> String? {
        return ts.t{_ in
            if let t = ts.read() {
                if t.isSymbol {
                    return t.value
                }
            }
            return nil
        }
    }
    
    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        if let s = readStringAtom(ts) {
            return Var(s)
        }
        return nil
    }
    
    public var description: String {
        return "\(name)"
    }
}