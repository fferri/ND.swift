import Foundation

func parse(s: String) -> Program? {
    let tokenStream = TokenStream(tokens: tokenize(s))
    if let p = Program.parse(tokenStream) {
        if tokenStream.pos >= tokenStream.tokens.count {
            return p
        }
    }
    if let t = tokenStream.read() {
        fatalError("unexpected \(t)")
    } else {
        fatalError("unexpected EOF")
    }
}
