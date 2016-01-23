import Foundation

public class Print : Program, CustomStringConvertible {
    let value: AlgebraicExpr
    
    init(_ value: AlgebraicExpr) {
        self.value = value
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        var r: (Program, State)? = (Empty(), s)
        return anyGenerator{
            let r1 = r
            r = nil
            print(self.value.eval(s))
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
            guard let t2 = ts.read() where t2.value == "print" else {break parse}
            guard let value = AlgebraicExpr.parse(ts) else {break parse}
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