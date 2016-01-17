import Foundation

public class RelationalOp : BoolExpr {
    override func eval(s: State) -> Bool {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> (AlgebraicExpr, AlgebraicExpr)? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == op else {break parse}
            guard let e1 = AlgebraicExpr.parse(ts) else {break parse}
            guard let e2 = AlgebraicExpr.parse(ts) else {break parse}
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return (e1, e2)
        }
        ts.pos = oldpos
        return nil
    }
}
