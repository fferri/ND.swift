import Foundation

public class AlgebraicExpr {
    public func eval(s: State) -> Int {
        fatalError()
    }

    static func readIntAtom(ts: TokenStream) -> Int? {
        return ts.t{_ in
            if let t = ts.read() {
                if let i = Int(t.value) {
                    return i
                }
            }
            return nil
        }
    }
    
    static func readStringAtom(ts: TokenStream) -> String? {
        return ts.t{_ in
            if let t = ts.read() {
                if t.isSymbol {
                    return t.value
                }
            }
            return nil
        }
    }
    
    static func readOp(ts: TokenStream, op: String) -> [AlgebraicExpr]? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            var e = [AlgebraicExpr]()
            while let en = AlgebraicExpr.readAlgebraicExpr(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return e.count >= 2 ? e : nil
        }
    }
    
    static func readAlgebraicExpr(ts: TokenStream) -> AlgebraicExpr? {
        if let x = Const.readConst(ts) {return x}
        if let x = Var.readVar(ts) {return x}
        if let x = Add.readAdd(ts) {return x}
        if let x = Sub.readSub(ts) {return x}
        if let x = Mul.readMul(ts) {return x}
        if let x = Div.readDiv(ts) {return x}
        return nil
    }
}



