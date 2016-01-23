import Foundation

public class Var : AlgebraicExpr {
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
    
    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        let oldpos = ts.pos
        parse: do {
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            return Var(name)
        }
        ts.pos = oldpos
        return nil
    }
    
    public override var description: String {
        return "\(name)"
    }
}