import Foundation

public class AlgebraicOp : AlgebraicExpr {
    public override func eval(s: State) -> Int {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> [AlgebraicExpr]? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            var e = [AlgebraicExpr]()
            while let en = AlgebraicExpr.parse(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return e.count >= 2 ? e : nil
        }
    }
}


