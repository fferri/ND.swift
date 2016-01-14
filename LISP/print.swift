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
        return true
    }
    
    class func readPrint(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "print" else {return nil}
            guard let value = AlgebraicExpr.parse(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return Print(value)
        }
    }
    
    public var description: String {
        return "(print \(value))"
    }
}
