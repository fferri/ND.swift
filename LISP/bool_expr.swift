import Foundation

public class BoolExpr {
    func eval(s: State) -> Bool {
        fatalError()
    }

    static func readRelOp(ts: TokenStream, op: String) -> (AlgebraicExpr, AlgebraicExpr)? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            guard let e1 = AlgebraicExpr.readAlgebraicExpr(ts) else {return nil}
            guard let e2 = AlgebraicExpr.readAlgebraicExpr(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return (e1, e2)
        }
    }
    
    static func readOp(ts: TokenStream, op: String) -> [BoolExpr]? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            var e = [BoolExpr]()
            while let en = BoolExpr.readBoolExpr(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return e.count >= 2 ? e : nil
        }
    }
    
    static func readBoolExpr(ts: TokenStream) -> BoolExpr? {
        if let x = And.readAnd(ts) {return x}
        if let x = Or.readOr(ts) {return x}
        if let x = Not.readNot(ts) {return x}
        if let x = LessThan.readLessThan(ts) {return x}
        if let x = Equal.readEqual(ts) {return x}
        if let x = GreaterThan.readGreaterThan(ts) {return x}
        return nil
    }
}
