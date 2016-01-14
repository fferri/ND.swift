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
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "while" else {return abort()}
        guard let cond = BoolExpr.parse(ts) else {return abort()}
        guard let body = Program.parse(ts) else {return abort()}
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return While(cond, body)
    }
    
    public var description: String {
        return "(while \(cond) \(body))"
    }
}
