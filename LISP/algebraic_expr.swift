import Foundation

public class AlgebraicExpr : CustomStringConvertible {
    public func eval(s: State) -> Int {
        fatalError()
    }
    
    class func parse(ts: TokenStream) -> AlgebraicExpr? {
        if let x = Const.parse(ts) {return x}
        if let x = Var.parse(ts) {return x}
        if let x = Add.parse(ts) {return x}
        if let x = Sub.parse(ts) {return x}
        if let x = Mul.parse(ts) {return x}
        if let x = Div.parse(ts) {return x}
        return nil
    }
    
    public var description: String {
        return "<expr>"
    }
}



