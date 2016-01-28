import Foundation

public indirect enum Value : CustomStringConvertible {
    case Boolean(Bool)
    case Integer(Int)
    case Floating(Double)
    case Str(String)
    case List(ListValue)
    
    public var description: String {
        switch(self) {
        case let .Boolean(v): return "\(v)"
        case let .Integer(v): return "\(v)"
        case let .Floating(v): return "\(v)"
        case let .Str(v): return "\(v)"
        case let .List(v): return "\(v)"
        }
    }
    
    public var asBool: Bool {
        switch(self) {
        case let .Boolean(v): return v
        default: fatalError("value expected to be boolean. found: \(self)")
        }
    }
    
    public var asInt: Int {
        switch(self) {
        case let .Integer(v): return v
        default: fatalError("value expected to be integer. found: \(self)")
        }
    }
    
    public var asDouble: Double {
        switch(self) {
        case let .Floating(v): return v
        default: fatalError("value expected to be floating. found: \(self)")
        }
    }
    
    public var asString: String {
        switch(self) {
        case let .Str(v): return v
        default: fatalError("value expected to be str. found: \(self)")
        }
    }
    
    public var asList: ListValue {
        switch(self) {
        case let .List(v): return v
        default: fatalError("value expected to be list. found: \(self)")
        }
    }
}

func ==(lhs: Value, rhs: Value) -> Bool {
    switch(lhs, rhs) {
    case let (.Boolean(v1), .Boolean(v2)): return v1 == v2
    case let (.Integer(v1), .Integer(v2)): return v1 == v2
    case let (.Floating(v1), .Floating(v2)): return v1 == v2
    case let (.Str(v1), .Str(v2)): return v1 == v2
    case let (.List(v1), .List(v2)): return v1 == v2
    default: fatalError("bad arguments to ==: \(lhs), \(rhs)")
    }
}

func +(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Integer(av + bv)
    case let (.Floating(av), .Floating(bv)):
        return .Floating(av + bv)
    case let (.Floating(av), .Integer(bv)):
        return .Floating(av + Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Floating(Double(av) + bv)
    case let (.Str(av), .Str(bv)):
        return .Str(av + bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for +")
    }
}

func -(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Integer(av - bv)
    case let (.Floating(av), .Floating(bv)):
        return .Floating(av - bv)
    case let (.Floating(av), .Integer(bv)):
        return .Floating(av - Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Floating(Double(av) - bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for -")
    }
}

func *(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Integer(av * bv)
    case let (.Floating(av), .Floating(bv)):
        return .Floating(av * bv)
    case let (.Floating(av), .Integer(bv)):
        return .Floating(av * Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Floating(Double(av) * bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for *")
    }
}

func /(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Integer(av / bv)
    case let (.Floating(av), .Floating(bv)):
        return .Floating(av / bv)
    case let (.Floating(av), .Integer(bv)):
        return .Floating(av / Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Floating(Double(av) / bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for /")
    }
}

func ==(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Boolean(av), .Boolean(bv)):
        return .Boolean(av == bv)
    case let (.Integer(av), .Integer(bv)):
        return .Boolean(av == bv)
    case let (.Floating(av), .Floating(bv)):
        return .Boolean(av == bv)
    case let (.Str(av), .Str(bv)):
        return .Boolean(av == bv)
    case let (.List(av), .List(bv)):
        return .Boolean(av == bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for =")
    }
}

func >(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Boolean(av > bv)
    case let (.Floating(av), .Floating(bv)):
        return .Boolean(av > bv)
    case let (.Floating(av), .Integer(bv)):
        return .Boolean(av > Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Boolean(Double(av) > bv)
    case let (.Str(av), .Str(bv)):
        return .Boolean(av > bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for >")
    }
}

func <(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Integer(av), .Integer(bv)):
        return .Boolean(av < bv)
    case let (.Floating(av), .Floating(bv)):
        return .Boolean(av < bv)
    case let (.Floating(av), .Integer(bv)):
        return .Boolean(av < Double(bv))
    case let (.Integer(av), .Floating(bv)):
        return .Boolean(Double(av) < bv)
    case let (.Str(av), .Str(bv)):
        return .Boolean(av < bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for >")
    }
}

func &&(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Boolean(av), .Boolean(bv)):
        return .Boolean(av && bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for and")
    }
}

func ||(lhs: Value, rhs: Value) -> Value {
    switch(lhs, rhs) {
    case let (.Boolean(av), .Boolean(bv)):
        return .Boolean(av || bv)
    default:
        fatalError("invalid operands \(lhs), \(rhs) for or")
    }
}

prefix func !(rhs: Value) -> Value {
    switch(rhs) {
    case let .Boolean(ev):
        return .Boolean(!ev)
    default:
        fatalError("invalid operand \(rhs) for not")
    }
}

func head(v: Value) -> Value {
    switch(v) {
    case let (.List(l)):
        return head(l)
    default:
        fatalError("invalid operand \(v) for head")
    }
}

func tail(v: Value) -> Value {
    switch(v) {
    case let (.List(l)):
        return .List(tail(l))
    default:
        fatalError("invalid operand \(v) for tail")
    }
}

func cons(h: Value, _ t: Value) -> Value {
    switch(t) {
    case let (.List(v)):
        return .List(cons(h, v))
    default:
        fatalError("invalid 2nd operand \(t) for cons")
    }
}

func any(g: AnyGenerator<Value>) -> Bool {
    return any(g) {
        x in x.asBool
    }
}

func all(g: AnyGenerator<Value>) -> Bool {
    return all(g) {
        x in x.asBool
    }
}
