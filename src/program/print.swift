import Foundation

public class Print : Program, CustomStringConvertible {
    let value: Expr
    
    init(_ value: Expr) {
        self.value = value
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        return transformGenerator(value.eval(s)) {
            x in
            print(x)
            return (Empty(), s)
        }
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "print" else {break parse}
            guard let value = Expr.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return Print(value)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(print \(value))"
    }
}
