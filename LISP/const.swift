import Foundation

public class Const : AlgebraicExpr, CustomStringConvertible {
    var value: Int = 0
    
    init(_ v: Int) {
        value = v
    }
    
    public override func eval(s: State) -> Int {
        return value
    }

    class func readIntAtom(ts: TokenStream) -> Int? {
        return ts.t{_ in
            if let t = ts.read() {
                if let i = Int(t.value) {
                    return i
                }
            }
            return nil
        }
    }
    
    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        if let i = readIntAtom(ts) {
            return Const(i)
        }
        return nil
    }
    
    public var description: String {
        return "\(value)"
    }
}