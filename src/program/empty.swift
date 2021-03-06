import Foundation

public class Empty : Program, CustomStringConvertible {
    public override func trans(s: State) -> AnyGenerator<(Program, State)> {
        return emptyGenerator()
    }
    
    public override func final(s: State) -> Bool {
        return true
    }
    
    public var description: String {
        return "()"
    }
}
