import Foundation

public class BoolOp : BoolExpr {
    override func eval(s: State) -> Bool {
        fatalError()
    }
    
    class func parse(ts: TokenStream, op: String) -> [BoolExpr]? {
        let oldpos = ts.pos
        let abort = {() -> [BoolExpr]? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == op else {return abort()}
        var e = [BoolExpr]()
        while let en = BoolExpr.parse(ts) {
            e.append(en)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return e.count >= 2 ? e : abort()
    }
}
