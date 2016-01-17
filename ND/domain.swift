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
        parse: do {
            guard let t1 = ts.read() where t1.value == "(" else {break parse}
            guard let t2 = ts.read() where t2.value == "domain" else {break parse}
            guard let namet = ts.read() where namet.isSymbol else {break parse}
            let name = namet.value
            var values = [AlgebraicExpr]()
            while let value = AlgebraicExpr.parse(ts) {
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
