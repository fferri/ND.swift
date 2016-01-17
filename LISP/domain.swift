import Foundation

public class Domain : Program, CustomStringConvertible {
    let name: String
    let values: [AlgebraicExpr]
    
    init(_ name: String, _ values: [AlgebraicExpr]) {
        self.name = name
        self.values = values
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        var i = 0
        return anyGenerator{
            var s1 = s
            if i < self.values.count {
                s1[self.name] = self.values[i].eval(s)
                i += 1
                return (Empty(), s1)
            } else {
                return nil
            }
        }
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        let abort = {() -> Program? in ts.pos = oldpos; return nil}
        guard let t1 = ts.read() where t1.value == "(" else {return abort()}
        guard let t2 = ts.read() where t2.value == "domain" else {return abort()}
        guard let name = Var.readStringAtom(ts) else {return abort()}
        var values = [AlgebraicExpr]()
        while let value = AlgebraicExpr.parse(ts) {
            values.append(value)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return abort()}
        return Domain(name, values)
    }
    
    public var description: String {
        return "(domain \(name) \(values.map{String($0)}.joinWithSeparator(" ")))"
    }
}
