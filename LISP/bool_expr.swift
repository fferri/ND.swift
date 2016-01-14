import Foundation

public class BoolExpr {
    func eval(s: State) -> Bool {
        fatalError()
    }
    
    class func parse(ts: TokenStream) -> BoolExpr? {
        if let x = And.parse(ts) {return x}
        if let x = Or.parse(ts) {return x}
        if let x = Not.parse(ts) {return x}
        if let x = LessThan.parse(ts) {return x}
        if let x = Equal.parse(ts) {return x}
        if let x = GreaterThan.parse(ts) {return x}
        return nil
    }
}
