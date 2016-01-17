import Foundation

class TokenStream {
    let tokens: [Token]
    var pos: Int = 0
    var savedPos: Int = 0
    
    init(tokens t: [Token] = []) {
        tokens = t
    }
    
    func read() -> Token? {
        if pos >= tokens.count {return nil}
        defer {pos += 1}
        return tokens[pos]
    }
}
