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

    class func readStringAtom(ts: TokenStream) -> String? {
        let oldpos = ts.pos
        let abort = {() -> String? in ts.pos = oldpos; return nil}
        if let t = ts.read() {
            if t.isSymbol {
                return t.value
            }
        }
        return abort()
    }
    
    override class func parse(ts: TokenStream) -> AlgebraicExpr? {
        if let s = readStringAtom(ts) {
            return Var(s)
        }
        return nil
    }
    
    public override var description: String {
        return "\(name)"
    }
}