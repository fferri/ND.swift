import Foundation

public class Assign : Program, CustomStringConvertible {
    let name: String
    let value: AlgebraicExpr
    
    init(_ name: String, _ value: AlgebraicExpr) {
        self.name = name
        self.value = value
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        var s1 = s
        s1[self.name] = self.value.eval(s)
        var r: (Program, State)? = (Empty(), s1)
        return anyGenerator{
            let r1 = r
            r = nil
            return r1
        }
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "set" else {break parse}
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            guard let value = AlgebraicExpr.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return Assign(name, value)
        }
        ts.pos = oldpos
        return nil
    }

    public var description: String {
        return "(set \(name) \(value))"
    }
}