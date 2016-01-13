import Foundation

struct Position : CustomStringConvertible {
    var line = 1
    var column = 0
    var description: String {return "line \(line) column \(column)"}
}

struct Token : CustomStringConvertible {
    var value = ""
    var position = Position()
    var length: Int {return value.characters.count}
    var description: String {return "\"\(value)\" at \(position)"}
    var isNumber: Bool {
        if let _ = Int(value) {return true} else {return false}
    }
    var isSpecial: Bool {
        return value == "(" || value == ")"
    }
    var isSymbol: Bool {
        return !isNumber && !isSpecial
    }
}
