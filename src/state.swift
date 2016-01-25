import Foundation

public struct State {
    var env = Dictionary<String, Value>()
    var funcs = Dictionary<String, FuncDecl>()
    
    init(_ d: Dictionary<String, Value> = [:]) {
        env = d
    }
    
    subscript(s: String) -> Value? {
        get {return env[s]}
        set {env[s] = newValue}
    }
    
    public var description: String {
        return "State(\(env))"
    }
}
