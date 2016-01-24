import Foundation

public class NAryOperator : Expr {
    public override func eval(s: State) -> Value {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String, minArity: Int? = nil, maxArity: Int? = nil) -> [Expr]? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == op else {break parse}
            var e = [Expr]()
            while let en = Expr.parse(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            if minArity != nil && e.count < minArity! {break parse}
            if maxArity != nil && e.count > maxArity! {break parse}
            return e
        }
        ts.pos = oldpos
        return nil
    }
}
