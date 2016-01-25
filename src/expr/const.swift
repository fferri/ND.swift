import Foundation

public class Const : Expr {
    var value: Value
    
    init(_ v: Value) {
        value = v
    }
    
    public override func eval(s: State) -> Value {
        return value
    }
    
    override class func parse(ts: TokenStream) -> Expr? {
        if let x = parseBoolLiteral(ts) {return Const(x)}
        if let x = parseIntLiteral(ts) {return Const(x)}
        if let x = parseDoubleLiteral(ts) {return Const(x)}
        if let x = parseStringLiteral(ts) {return Const(x)}
        if let x = parseListLiteral(ts) {return Const(x)}
        return nil
    }
    
    class func parseBoolLiteral(ts: TokenStream) -> Value? {
        let oldpos = ts.pos
        parse: do {
            guard let valuet = ts.read() where valuet.isSymbol else {break parse}
            switch(valuet.value) {
            case "true": return .Boolean(true)
            case "false": return .Boolean(false)
            default: break parse
            }
        }
        ts.pos = oldpos
        return nil
    }
    
    class func parseIntLiteral(ts: TokenStream) -> Value? {
        let oldpos = ts.pos
        parse: do {
            guard let valuet = ts.read() where valuet.isInteger else {break parse}
            return .Integer(Int(valuet.value)!)
        }
        ts.pos = oldpos
        return nil
    }
    
    class func parseDoubleLiteral(ts: TokenStream) -> Value? {
        let oldpos = ts.pos
        parse: do {
            guard let valuet = ts.read() where valuet.isFloating else {break parse}
            return .Floating(Double(valuet.value)!)
        }
        ts.pos = oldpos
        return nil
    }
    
    class func parseStringLiteral(ts: TokenStream) -> Value? {
        let oldpos = ts.pos
        parse: do {
            guard let valuet = ts.read() where valuet.isString else {break parse}
            let s = valuet.value
            return .Str(s)
        }
        ts.pos = oldpos
        return nil
    }
    
    class func parseListLiteral(ts: TokenStream) -> Value? {
        return nil
    }
    
    public override var description: String {
        return "\(value)"
    }
}