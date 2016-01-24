import Foundation

public class Assign : Program, CustomStringConvertible {
    let name: String
    let value: Expr
    
    init(_ name: String, _ value: Expr) {
        self.name = name
        self.value = value
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        return generateOnce{
            var s1 = s
            s1[self.name] = self.value.eval(s)
            return (Empty(), s1)
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
            guard let value = Expr.parse(ts) else {break parse}
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
