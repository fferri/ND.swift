import Foundation

public class AlgebraicOp : AlgebraicExpr {
    public override func eval(s: State) -> Int {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> [AlgebraicExpr]? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == op else {break parse}
            var e = [AlgebraicExpr]()
            while let en = AlgebraicExpr.parse(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            if e.count < 2 {break parse}
            return e
        }
        ts.pos = oldpos
        return nil
    }
}
