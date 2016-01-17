import Foundation

public class Const : AlgebraicExpr {
    var value: Int = 0
    
    init(_ v: Int) {
        value = v
    }
    
    public override func eval(s: State) -> Int {
        return value
    }
    
    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        let oldpos = ts.pos
        parse: do {
            guard let valuet = ts.read() where valuet.isNumber else {break parse}
            let value = Int(valuet.value)!
            return Const(value)
        }
        ts.pos = oldpos
        return nil    }
    
    public override var description: String {
        return "\(value)"
    }
}