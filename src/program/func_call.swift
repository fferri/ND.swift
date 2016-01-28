import Foundation

public class FuncCall : Program, CustomStringConvertible {
    let name: String
    let args: [Expr]
    
    init(_ name: String, _ args: [Expr]) {
        self.name = name
        self.args = args
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        let funcCall = s.funcs[self.name]!
        return chainGenerators(transformGenerator(generatorProduct(args.map{e in e.eval(s)})) {
            x in
            var s1 = s
            for (argName, argExprVal) in zip(funcCall.args, x) {
                s1[argName] = argExprVal
            }
            return funcCall.body.trans(s1)
        })
    }
    
    override public func final(s: State) -> Bool {
        if let funcCall = s.funcs[name] {
            return funcCall.body.final(s)
        }
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            var args = [Expr]()
            while let expr = Expr.parse(ts) {
                args.append(expr)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return FuncCall(name, args)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(\(name) \(args.map{String($0)}.joinWithSeparator(" ")))"
    }
}
