import Foundation

public class RelationalOp : BoolExpr {
    override func eval(s: State) -> Bool {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> (AlgebraicExpr, AlgebraicExpr)? {
        let oldpos = ts.pos
        let abort = {() -> (AlgebraicExpr, AlgebraicExpr)? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == op else {return abort()}
        guard let e1 = AlgebraicExpr.parse(ts) else {return abort()}
        guard let e2 = AlgebraicExpr.parse(ts) else {return abort()}
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return (e1, e2)
    }
}