import Foundation

public class Assign : Program, CustomStringConvertible {
    let name: String
    let value: AlgebraicExpr
    
    init(_ name: String, _ value: AlgebraicExpr) {
        self.name = name
        self.value = value
    }
    
    public override func trans(s: State) -> (Program, State)? {
        var s1 = s
        s1[name] = value.eval(s)
        return (Empty(), s1)
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "set" else {return nil}
            guard let name = Var.readStringAtom(ts) else {return nil}
            guard let value = AlgebraicExpr.parse(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return Assign(name, value)
        }
    }
    
    public var description: String {
        return "(set \(name) \(value))"
    }
}
