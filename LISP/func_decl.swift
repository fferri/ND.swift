import Foundation

public class FuncDecl : Program, CustomStringConvertible {
    let name: String
    let args: [String]
    let body: Program
    
    init(_ name: String, _ args: [String], _ body: Program) {
        self.name = name
        self.args = args
        self.body = body
    }
    
    public override func trans(s: State) -> (Program, State)? {
        var s1 = s
        s1.funcs[name] = self
        return (Empty(), s1)
    }
    
    override public func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "def" else {return abort()}
        guard let namet = ts.read() where namet.isSymbol else {return abort()}
        let name = namet.value
        guard let t3 = ts.read() where t3.value == "(" else {return abort()}
        var args = [String]()
        while let argt = ts.read() where argt.isSymbol {
            args.append(argt.value)
        }
        ts.pos -= 1
        guard let t4 = ts.read() where t4.value == ")" else {return abort()}
        guard let body = Program.parse(ts) else {return abort()}
        guard let t5 = ts.read() where t5.value == ")" else {return abort()}
        return FuncDecl(name, args, body)
    }
    
    public var description: String {
        var argsStr = ""
        for arg in args {
            argsStr += (argsStr == "" ? "" : " ") + arg
        }
        return "(def \(name) (\(argsStr)) \(body))"
    }
}
