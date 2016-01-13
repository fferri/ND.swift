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

protocol AlgebraicExpr {
    func eval(s: State) -> Int
}

public struct Const : AlgebraicExpr {
    var value: Int = 0
    
    public func eval(s: State) -> Int {
        return value
    }
}

public struct Var : AlgebraicExpr {
    var name: String = ""
    
    public func eval(s: State) -> Int {
        if let v = s[name] {
            return v
        } else {
            fatalError("no such variable: \(name)")
        }
    }
}

public struct Add : AlgebraicExpr {
    let a, b: AlgebraicExpr

    public func eval(s: State) -> Int {
        return a.eval(s) + b.eval(s)
    }
}

public struct Sub : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Int {
        return a.eval(s) - b.eval(s)
    }
}

public struct Mul : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Int {
        return a.eval(s) * b.eval(s)
    }
}

public struct Div : AlgebraicExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Int {
        return a.eval(s) / b.eval(s)
    }
}

protocol BoolExpr {
    func eval(s: State) -> Bool
}

public struct LessThan : BoolExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Bool {
        return a.eval(s) < b.eval(s)
    }
}

public struct Equal : BoolExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Bool {
        return a.eval(s) == b.eval(s)
    }
}

public struct GreaterThan : BoolExpr {
    let a, b: AlgebraicExpr
    
    public func eval(s: State) -> Bool {
        return a.eval(s) > b.eval(s)
    }
}

public struct And : BoolExpr {
    let a, b: BoolExpr
    
    public func eval(s: State) -> Bool {
        return a.eval(s) && b.eval(s)
    }
}

public struct Or : BoolExpr {
    let a, b: BoolExpr
    
    public func eval(s: State) -> Bool {
        return a.eval(s) || b.eval(s)
    }
}

public struct Not : BoolExpr {
    let e: BoolExpr
    
    public func eval(s: State) -> Bool {
        return !e.eval(s)
    }
}

public protocol Program {
    func trans(s: State) -> (Program, State)? /* AnyGenerator<(Program, State)> */
    func final(s: State) -> Bool
}

public struct Empty : Program {
    public func trans(s: State) -> (Program, State)? {return nil}
    public func final(s: State) -> Bool {return true}
}

public struct Sequence : Program {
    let p1, p2: Program
    
    public func trans(s: State) -> (Program, State)? {
        if p1.final(s) {return p2.trans(s)}
        let (p11, s1) = p1.trans(s)!
        return (Sequence(p1: p11, p2: p2), s1)
    }
    
    public func final(s: State) -> Bool {
        return p1.final(s) && p2.final(s)
    }
}

public struct Assign : Program {
    let name: String
    let value: AlgebraicExpr
    
    public func trans(s: State) -> (Program, State)? {
        var s1 = s
        s1[name] = value.eval(s)
        return (Empty(), s1)
    }
    
    public func final(s: State) -> Bool {
        return false
    }
}

public struct If : Program {
    let cond: BoolExpr
    let body: Program
    
    public func trans(s: State) -> (Program, State)? {
        if cond.eval(s) {
            return body.trans(s)!
        } else {
            return (Empty(), s)
        }
    }
    
    public func final(s: State) -> Bool {
        return !cond.eval(s) || body.final(s)
    }
}

public struct While : Program {
    let cond: BoolExpr
    let body: Program
    
    public func trans(s: State) -> (Program, State)? {
        if cond.eval(s) {
            let (p11, s1) = body.trans(s)!
            return (Sequence(p1: p11, p2: self), s1)
        }
        return nil
    }
    
    public func final(s: State) -> Bool {
        return !cond.eval(s) || body.final(s)
    }
}

public extension Program {
    public func exec(s: State) -> State {
        if final(s) {return s}
        let (p1, s1) = trans(s)!
        return p1.exec(s1)
    }
}

