import Foundation

public class Expr : CustomStringConvertible {
    public func eval(s: State) -> AnyGenerator<Value> {
        fatalError()
    }
    
    class func parse(ts: TokenStream) -> Expr? {
        if let x = Const.parse(ts) {return x}
        if let x = Var.parse(ts) {return x}
        if let x = Add.parse(ts) {return x}
        if let x = Sub.parse(ts) {return x}
        if let x = Mul.parse(ts) {return x}
        if let x = Div.parse(ts) {return x}
        if let x = And.parse(ts) {return x}
        if let x = Or.parse(ts) {return x}
        if let x = Not.parse(ts) {return x}
        if let x = LessThan.parse(ts) {return x}
        if let x = Equal.parse(ts) {return x}
        if let x = GreaterThan.parse(ts) {return x}
        if let x = Head.parse(ts) {return x}
        if let x = Tail.parse(ts) {return x}
        if let x = Cons.parse(ts) {return x}
        if let x = Len.parse(ts) {return x}
        if let x = ChooseExpr.parse(ts) {return x}
        if let x = List.parse(ts) {return x} // must try this as last
        return nil
    }
    
    public var description: String {
        fatalError()
    }
}
