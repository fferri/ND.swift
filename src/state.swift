import Foundation

public struct State {
    var env = Dictionary<String, Int>()
    var funcs = Dictionary<String, FuncDecl>()
    
    init(_ d: Dictionary<String, Int> = [:]) {
        env = d
    }
    
    subscript(s: String) -> Int? {
        get {return env[s]}
        set {env[s] = newValue}
    }
    
    public var description: String {
        return "State(\(env))"
    }
}
