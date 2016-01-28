import Foundation

public class Domain : Program, CustomStringConvertible {
    let name: String
    let values: [Expr]
    
    init(_ name: String, _ values: [Expr]) {
        self.name = name
        self.values = values
    }
    
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        return transformGenerator(chainGenerators(values.map{$0.eval(s)})) {
            x in
            var s1 = s
            s1[self.name] = x
            return (Empty(), s1)
        }
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
    
    override class func parse(ts: TokenStream) -> Program? {
        let oldpos = ts.pos
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "domain" else {break parse}
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            var values = [Expr]()
            while let value = Expr.parse(ts) {
                values.append(value)
            }
            guard let t3 = ts.read() where t3.value == ")" else {break parse}
            return Domain(name, values)
        }
        ts.pos = oldpos
        return nil
    }
    
    public var description: String {
        return "(domain \(name) \(values.map{String($0)}.joinWithSeparator(" ")))"
    }
}
