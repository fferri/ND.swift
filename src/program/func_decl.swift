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
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        return generateOnce{
            var s1 = s
            s1.funcs[self.name] = self
            return (Empty(), s1)
        }
    }
    
    override public func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "def" else {break parse}
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            guard let t3 = ts.read() where t3.value == "(" else {break parse}
            var args = [String]()
            while let argt = ts.read() where argt.isSymbol {
                args.append(argt.value)
            }
            ts.pos -= 1
            guard let t4 = ts.read() where t4.value == ")" else {break parse}
            guard let body = Program.parse(ts) else {break parse}
            guard let t5 = ts.read() where t5.value == ")" else {break parse}
            return FuncDecl(name, args, body)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(def \(name) (\(args.map{String($0)}.joinWithSeparator(" "))) \(body))"
    }
}
