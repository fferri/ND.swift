import Foundation

public class FuncCall : Program, CustomStringConvertible {
    let name: String
    let args: [AlgebraicExpr]
    
    init(_ name: String, _ args: [AlgebraicExpr]) {
        self.name = name
        self.args = args
    }
    
    public override func trans(s: State) -> (Program, State)? {
        let funcCall = s.funcs[name]!
        var s1 = s
        for (argName, argExpr) in zip(funcCall.args, args) {
            s1[argName] = argExpr.eval(s1)
        }
        return funcCall.body.trans(s1)!
    }
    
    override public func final(s: State) -> Bool {
        if let funcCall = s.funcs[name] {
            return funcCall.body.final(s)
        }
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let namet = ts.read() where namet.isSymbol else {return abort()}
        let name = namet.value
        var args = [AlgebraicExpr]()
        while let expr = AlgebraicExpr.parse(ts) {
            args.append(expr)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return FuncCall(name, args)
    }
    
    public var description: String {
        var argsStr = ""
        for arg in args {
            argsStr += (argsStr == "" ? "" : " ") + arg.description
        }
        return "(\(name) \(argsStr))"
    }
}
