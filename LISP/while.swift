import Foundation

public class While : Program, CustomStringConvertible {
    let cond: BoolExpr
    let body: Program
    
    init(_ cond: BoolExpr, _ body: Program) {
        self.cond = cond
        self.body = body
    }
    
    public override func trans(s: State) -> (Program, State)? {
        if cond.eval(s) {
            let (p11, s1) = body.trans(s)!
            return (Sequence(p11, self), s1)
        }
        return nil
    }
    
    public override func final(s: State) -> Bool {
        return !cond.eval(s) || body.final(s)
    }
    
    static func readWhile(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "while" else {return nil}
            guard let cond = BoolExpr.readBoolExpr(ts) else {return nil}
            guard let body = Program.readProgram(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return While(cond, body)
        }
    }
    
    public var description: String {
        return "(while \(cond) \(body))"
    }
}
