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

public protocol Evaluable {
    typealias ReturnType
    func eval(s: State) -> ReturnType
}

public indirect enum Expr : Evaluable {
    case Const(x: Int)
    case Var(n: String)
    case Add(a: Expr, b: Expr)
    case Sub(a: Expr, b: Expr)
    
    public func eval(s: State) -> Int {
        switch(self) {
        case .Const(let x): return x
        case .Var(let n): if let v = s[n] {return v} else {fatalError("no such variable \(n)")}
        case .Add(let a, let b): return a.eval(s) + b.eval(s)
        case .Sub(let a, let b): return a.eval(s) - b.eval(s)
        }
    }
}

public indirect enum BoolExpr : Evaluable {
    case LessThan(a: Expr, b: Expr)
    case Equal(a: Expr, b: Expr)
    case GreaterThan(a: Expr, b: Expr)
    case And(a: BoolExpr, b: BoolExpr)
    case Or(a: BoolExpr, b: BoolExpr)
    case Not(e: BoolExpr)
    
    public func eval(s: State) -> Bool {
        switch(self) {
        case .LessThan(let a, let b): return a.eval(s) < b.eval(s)
        case .Equal(let a, let b): return a.eval(s) == b.eval(s)
        case .GreaterThan(let a, let b): return a.eval(s) > b.eval(s)
        case .And(let a, let b): return a.eval(s) && b.eval(s)
        case .Or(let a, let b): return a.eval(s) || b.eval(s)
        case .Not(let e): return !e.eval(s)
        }
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
    let value: Expr
    
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

