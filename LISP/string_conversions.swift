import Foundation

extension Node : CustomStringConvertible {
    var description: String {
        switch(self) {
        case Comp(let a): return "\(a)"
        case Symbol(let a): return "\"\(a)\""
        case Number(let a): return "\(a)"
        }
    }
}

extension State : CustomStringConvertible {
    public var description: String {
        return "State(\(env))"
    }
}

extension Expr : CustomStringConvertible {
    public var description: String {
        switch(self) {
        case let .Const(x): return "\(x)"
        case let .Var(x): return "?\(x)"
        case let .Add(a, b): return "(+ \(a) \(b))"
        case let .Sub(a, b): return "(- \(a) \(b))"
        case let .Mul(a, b): return "(* \(a) \(b))"
        case let .Div(a, b): return "(/ \(a) \(b))"
        }
    }
}

extension BoolExpr : CustomStringConvertible {
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

extension Empty : CustomStringConvertible {
    public var description: String {
        return "()"
    }
}

extension Sequence : CustomStringConvertible {
    public var description: String {
        return "(\(p1) \(p2))"
    }
}

extension Assign : CustomStringConvertible {
    public var description: String {
        return "(set \(name) \(value))"
    }
}

extension If : CustomStringConvertible {
    public var description: String {
        return "(if \(cond) \(body))"
    }
}

extension While : CustomStringConvertible {
    public var description: String {
        return "(while \(cond) \(body))"
    }
}

