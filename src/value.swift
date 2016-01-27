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
