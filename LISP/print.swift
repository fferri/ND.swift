import Foundation

public class Print : Program, CustomStringConvertible {
    let value: AlgebraicExpr
    
    init(_ value: AlgebraicExpr) {
        self.value = value
    }
    
    public override func trans(s: State) -> (Program, State)? {
        print(value.eval(s))
        return (Empty(), s)
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "print" else {return abort()}
        guard let value = AlgebraicExpr.parse(ts) else {return abort()}
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return Print(value)
    }
    
    public var description: String {
        return "(print \(value))"
    }
}
