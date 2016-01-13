import Foundation

extension State : CustomStringConvertible {
    public var description: String {
        return "State(\(env))"
    }
}

extension Const : CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

extension Var : CustomStringConvertible {
    public var description: String {
        return "?\(name)"
    }
}

extension Add : CustomStringConvertible {
    public var description: String {
        return "(+ \(a) \(b))"
    }
}

extension Sub : CustomStringConvertible {
    public var description: String {
        return "(- \(a) \(b))"
    }
}

extension Mul : CustomStringConvertible {
    public var description: String {
        return "(* \(a) \(b))"
    }
}

extension Div : CustomStringConvertible {
    public var description: String {
        return "(/ \(a) \(b))"
    }
}

extension LessThan : CustomStringConvertible {
    public var description: String {
        return "(< \(a) \(b))"
    }
}

extension Equal : CustomStringConvertible {
    public var description: String {
        return "(= \(a) \(b))"
    }
}

extension GreaterThan : CustomStringConvertible {
    public var description: String {
        return "(> \(a) \(b))"
    }
}

extension And : CustomStringConvertible {
    public var description: String {
        return "(and \(a) \(b))"
    }
}

extension Or : CustomStringConvertible {
    public var description: String {
        return "(or \(a) \(b))"
    }
}

extension Not : CustomStringConvertible {
    public var description: String {
        return "(not \(e))"
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

