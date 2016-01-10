import Foundation

public struct State : CustomStringConvertible {
    private var env = Dictionary<String, Int>()
    public var description: String {
        return "State(\(env))"
    }
    
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

public indirect enum Expr : Evaluable, CustomStringConvertible {
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
    
    public var description: String {
        switch(self) {
        case let .Const(x): return "\(x)"
        case let .Var(x): return "?\(x)"
        case let .Add(a, b): return "(+ \(a) \(b))"
        case let .Sub(a, b): return "(- \(a) \(b))"
        }
    }
}

public indirect enum BoolExpr : Evaluable, CustomStringConvertible {
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
    
    public var description: String {
        switch(self) {
        case let .LessThan(a, b): return "(< \(a) \(b))"
        case let .Equal(a, b): return "(= \(a) \(b))"
        case let .GreaterThan(a, b): return "(> \(a) \(b))"
        case let .And(a, b): return "(and \(a) \(b))"
        case let .Or(a, b): return "(or \(a) \(b))"
        case let .Not(e): return "(not \(e))"
        }
    }
}

public protocol Program {
    func trans(s: State) -> (Program, State)? /* AnyGenerator<(Program, State)> */
    func final(s: State) -> Bool
}

public struct Empty : Program, CustomStringConvertible {
    public func trans(s: State) -> (Program, State)? {return nil}
    public func final(s: State) -> Bool {return true}
    public var description: String {return "()"}
}

public struct Sequence : Program, CustomStringConvertible {
    let p1, p2: Program
    
    public func trans(s: State) -> (Program, State)? {
        if p1.final(s) {return p2.trans(s)}
        let (p11, s1) = p1.trans(s)!
        return (Sequence(p1: p11, p2: p2), s1)
    }
    
    public func final(s: State) -> Bool {
        return p1.final(s) && p2.final(s)
    }
    
    public var description: String {return "(\(p1) \(p2))"}
}

public struct Assign : Program, CustomStringConvertible {
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
    
    public var description: String {return "(set \(name) \(value))"}
}

public struct If : Program, CustomStringConvertible {
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
    
    public var description: String {return "(if \(cond) \(body))"}
}

public struct While : Program, CustomStringConvertible {
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
    
    public var description: String {return "(while \(cond) \(body))"}
}

public extension Program {
    public func exec(s: State) -> State {
        if final(s) {return s}
        let (p1, s1) = trans(s)!
        return p1.exec(s1)
    }
}

