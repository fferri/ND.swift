import Foundation

public class BoolOp : BoolExpr {
    override func eval(s: State) -> Bool {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> [BoolExpr]? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == op else {break parse}
            var e = [BoolExpr]()
            while let en = BoolExpr.parse(ts) {
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
