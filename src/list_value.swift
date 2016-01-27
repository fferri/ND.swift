import Foundation

public indirect enum ListValue : CustomStringConvertible {
    case Nil
    case Node(Value, ListValue)
    
    public static func fromArray(v: [Value], startIndex: Int = 0) -> ListValue {
        if startIndex >= v.count {return .Nil}
        return .Node(v[startIndex], fromArray(v, startIndex: startIndex + 1))
    }
    
    public var toArray: [Value] {
        switch(self) {
        case .Nil: return []
        case let .Node(v, l): return [v] + l.toArray
        }
    }
    
    public var description: String {
        return "(" + toArray.map{String($0)}.joinWithSeparator(" ") + ")"
    }
}

func ==(lhs: ListValue, rhs: ListValue) -> Bool {
    switch(lhs, rhs) {
    case (.Nil, .Nil): return true
    case let (.Node(v1, l1), .Node(v2, l2)): return v1 == v2 && l1 == l2
    default: fatalError("bad arguments to ==: \(lhs), \(rhs)")
    }
}
