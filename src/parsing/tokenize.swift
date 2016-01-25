import Foundation

/// Tokenize, i.e. convert a string into an array of tokens
func tokenize(s: String) -> [Token] {
    var tokens = [Token]()
    var token = Token()
    var pos = Position()
    var (str, esc) = (false, false)
    for c in s.characters {
        pos.column += 1
        if c == "\n" {pos = Position(line: pos.line + 1, column: 0)}
        if esc {
            token.value.append(c)
            esc = false
        } else if !str && (c == " " || c == "\n" || c == "\t" || c == "(" || c == ")") {
            if token.length > 0 {
                tokens.append(token)
                token = Token()
            }
            token.position = pos
            token.position.column += 1
            if c == "(" || c == ")" {
                tokens.append(Token(value: String(c), position: pos, string: false))
            }
        } else if str && c == "\\" {
            esc = true
        } else if c == "\"" {
            str = !str
            token.string = true
        } else {
            token.value.append(c)
        }
    }
    if token.length > 0 {tokens.append(token)}
    return tokens
}
