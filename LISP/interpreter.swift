import Foundation

public struct State {
    var env = Dictionary<String, Int>()

    init(_ d: Dictionary<String, Int> = [:]) {
        env = d
    }
    
    subscript(s: String) -> Int? {
        get {return env[s]}
        set {env[s] = newValue}
    }
}

public class AlgebraicExpr {
    private init() {
    }
    
    public func eval(s: State) -> Int {
        return 0
    }
}

public class Const : AlgebraicExpr {
    var value: Int = 0
    
    init(_ v: Int) {
        value = v
    }
    
    public override func eval(s: State) -> Int {
        return value
    }
}

public class Var : AlgebraicExpr {
    var name: String = ""
    
    init(_ n: String) {
        name = n
    }
    
    public override func eval(s: State) -> Int {
        if let v = s[name] {
            return v
        } else {
            fatalError("no such variable: \(name)")
        }
    }
}

public class Add : AlgebraicExpr {
    let a, b: AlgebraicExpr

    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) + b.eval(s)
    }
}

public class Sub : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) - b.eval(s)
    }
}

public class Mul : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) * b.eval(s)
    }
}

public class Div : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Int {
        return a.eval(s) / b.eval(s)
    }
}

public class BoolExpr {
    private init() {
    }
    
    func eval(s: State) -> Bool {
        return false
    }
}

public class LessThan : BoolExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) < b.eval(s)
    }
}

public class Equal : BoolExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) == b.eval(s)
    }
}

public class GreaterThan : BoolExpr {
    let a, b: AlgebraicExpr
    
    init(_ a: AlgebraicExpr, _ b: AlgebraicExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) > b.eval(s)
    }
}

public class And : BoolExpr {
    let a, b: BoolExpr
    
    init(_ a: BoolExpr, _ b: BoolExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) && b.eval(s)
    }
}

public class Or : BoolExpr {
    let a, b: BoolExpr
    
    init(_ a: BoolExpr, _ b: BoolExpr) {
        self.a = a
        self.b = b
    }
    
    public override func eval(s: State) -> Bool {
        return a.eval(s) || b.eval(s)
    }
}

public class Not : BoolExpr {
    let e: BoolExpr
    
    init(_ e: BoolExpr) {
        self.e = e
    }
    
    public override func eval(s: State) -> Bool {
        return !e.eval(s)
    }
}

public class Program {
    private init() {
    }
    
    func trans(s: State) -> (Program, State)? /* AnyGenerator<(Program, State)> */ {
        return nil
    }
    
    func final(s: State) -> Bool {
        return false
    }
    
    public func exec(s: State) -> State {
        if final(s) {return s}
        let (p1, s1) = trans(s)!
        return p1.exec(s1)
    }
}

public class Empty : Program {
    override init() {}
    public override func trans(s: State) -> (Program, State)? {return nil}
    public override func final(s: State) -> Bool {return true}
}

public class Sequence : Program {
    let p1, p2: Program
    
    init(_ p1: Program, _ p2: Program) {
        self.p1 = p1
        self.p2 = p2
    }
    
    public override func trans(s: State) -> (Program, State)? {
        if p1.final(s) {return p2.trans(s)}
        let (p11, s1) = p1.trans(s)!
        return (Sequence(p11, p2), s1)
    }
    
    public override func final(s: State) -> Bool {
        return p1.final(s) && p2.final(s)
    }
}

public class Assign : Program {
    let name: String
    let value: AlgebraicExpr
    
    init(_ name: String, _ value: AlgebraicExpr) {
        self.name = name
        self.value = value
    }
    
    public override func trans(s: State) -> (Program, State)? {
        var s1 = s
        s1[name] = value.eval(s)
        return (Empty(), s1)
    }
    
    public override func final(s: State) -> Bool {
        return false
    }
}

public class If : Program {
    let cond: BoolExpr
    let body: Program
    
    init(_ cond: BoolExpr, _ body: Program) {
        self.cond = cond
        self.body = body
    }
    
    public override func trans(s: State) -> (Program, State)? {
        if cond.eval(s) {
            return body.trans(s)!
        } else {
            return (Empty(), s)
        }
    }
    
    override public func final(s: State) -> Bool {
        return !cond.eval(s) || body.final(s)
    }
}

public class While : Program {
    let cond: BoolExpr
    let body: Program
    
    init(_ cond: BoolExpr, _ body: Program) {
        self.cond = cond
        self.body = body
    }
    
    public override func trans(s: State) -> (Program, State)? {
        if cond.eval(s) {
            let (p11, s1) = body.trans(s)!
            return (Sequence(p11, self), s1)
        }
        return nil
    }
    
    public override func final(s: State) -> Bool {
        return !cond.eval(s) || body.final(s)
    }
}

