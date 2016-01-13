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
                tokens.append(Token(value: String(c), position: pos))
            }
        } else if str && c == "\\" {
            esc = true
        } else if c == "\"" {
            str = !str
        } else {
            token.value.append(c)
        }
    }
    if token.length > 0 {tokens.append(token)}
    return tokens
}

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
    
    func t<T>(f: TokenStream -> T?) -> T? {
        let oldpos = pos
        if let ret = f(self) {
            return ret
        }
        pos = oldpos
        return nil
    }
}

func readIntAtom(ts: TokenStream) -> Int? {
    return ts.t{_ in
        if let t = ts.read() {
            if let i = Int(t.value) {
                return i
            }
        }
        return nil
    }
}

func readStringAtom(ts: TokenStream) -> String? {
    return ts.t{_ in
        if let t = ts.read() {
            if t.isSymbol {
                return t.value
            }
        }
        return nil
    }
}

func readConst(ts: TokenStream) -> AlgebraicExpr? {
    if let i = readIntAtom(ts) {
        return Const(value: i)
    }
    return nil
}

func readVar(ts: TokenStream) -> AlgebraicExpr? {
    if let s = readStringAtom(ts) {
        return Var(name: s)
    }
    return nil
}

func readAlgebraicBinaryOp(ts: TokenStream, op: String) -> [AlgebraicExpr]? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == op else {return nil}
        var e = [AlgebraicExpr]()
        while let en = readAlgebraicExpr(ts) {
            e.append(en)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return e.count >= 2 ? e : nil
    }
}

func readAdd(ts: TokenStream) -> AlgebraicExpr? {
    guard let o = readAlgebraicBinaryOp(ts, op: "+") else {return nil}
    var e = Add(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = Add(a: e, b: o[i])
    }
    return e
}

func readSub(ts: TokenStream) -> AlgebraicExpr? {
    guard let o = readAlgebraicBinaryOp(ts, op: "-") else {return nil}
    var e = Sub(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = Sub(a: e, b: o[i])
    }
    return e
}

func readMul(ts: TokenStream) -> AlgebraicExpr? {
    guard let o = readAlgebraicBinaryOp(ts, op: "*") else {return nil}
    var e = Mul(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = Mul(a: e, b: o[i])
    }
    return e
}

func readDiv(ts: TokenStream) -> AlgebraicExpr? {
    guard let o = readAlgebraicBinaryOp(ts, op: "/") else {return nil}
    var e = Div(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = Div(a: e, b: o[i])
    }
    return e
}

func readAlgebraicExpr(ts: TokenStream) -> AlgebraicExpr? {
    if let x = readConst(ts) {return x}
    if let x = readVar(ts) {return x}
    if let x = readAdd(ts) {return x}
    if let x = readSub(ts) {return x}
    if let x = readMul(ts) {return x}
    if let x = readDiv(ts) {return x}
    return nil
}

func readBoolOp(ts: TokenStream, op: String) -> [BoolExpr]? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == op else {return nil}
        var e = [BoolExpr]()
        while let en = readBoolExpr(ts) {
            e.append(en)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return e.count >= 2 ? e : nil
    }
}

func readAnd(ts: TokenStream) -> BoolExpr? {
    guard let o = readBoolOp(ts, op: "and") else {return nil}
    var e = And(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = And(a: e, b: o[i])
    }
    return e
}

func readOr(ts: TokenStream) -> BoolExpr? {
    guard let o = readBoolOp(ts, op: "or") else {return nil}
    var e = Or(a: o[0], b: o[1])
    for i in 2..<o.count {
        e = Or(a: e, b: o[i])
    }
    return e}

func readNot(ts: TokenStream) -> BoolExpr? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == "not" else {return nil}
        guard let e1 = readBoolExpr(ts) else {return nil}
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return Not(e: e1)
    }
}

func readRelationalOp(ts: TokenStream, op: String) -> (AlgebraicExpr, AlgebraicExpr)? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == op else {return nil}
        guard let e1 = readAlgebraicExpr(ts) else {return nil}
        guard let e2 = readAlgebraicExpr(ts) else {return nil}
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return (e1, e2)
    }
}

func readLessThan(ts: TokenStream) -> BoolExpr? {
    guard let (e1, e2) = readRelationalOp(ts, op: "<") else {return nil}
    return LessThan(a: e1, b: e2)
}

func readEqual(ts: TokenStream) -> BoolExpr? {
    guard let (e1, e2) = readRelationalOp(ts, op: "=") else {return nil}
    return Equal(a: e1, b: e2)
}

func readGreaterThan(ts: TokenStream) -> BoolExpr? {
    guard let (e1, e2) = readRelationalOp(ts, op: ">") else {return nil}
    return GreaterThan(a: e1, b: e2)
}

func readBoolExpr(ts: TokenStream) -> BoolExpr? {
    if let x = readAnd(ts) {return x}
    if let x = readOr(ts) {return x}
    if let x = readNot(ts) {return x}
    if let x = readLessThan(ts) {return x}
    if let x = readEqual(ts) {return x}
    if let x = readGreaterThan(ts) {return x}
    return nil
}

func readSequence(ts: TokenStream) -> Program? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let p1 = readProgram(ts) else {return nil}
        guard let p2 = readProgram(ts) else {return nil}
        var p = Sequence(p1: p1, p2: p2)
        while let pn = readProgram(ts) {
            p = Sequence(p1: p, p2: pn)
        }
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return p
    }
}

func readAssign(ts: TokenStream) -> Program? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == "set" else {return nil}
        guard let name = readStringAtom(ts) else {return nil}
        guard let value = readAlgebraicExpr(ts) else {return nil}
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return Assign(name: name, value: value)
    }
}

func readIf(ts: TokenStream) -> Program? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == "if" else {return nil}
        guard let cond = readBoolExpr(ts) else {return nil}
        guard let body = readProgram(ts) else {return nil}
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return If(cond: cond, body: body)
    }
}

func readWhile(ts: TokenStream) -> Program? {
    return ts.t{_ in
        guard let t1 = ts.read() where t1.value == "(" else {return nil}
        guard let t2 = ts.read() where t2.value == "while" else {return nil}
        guard let cond = readBoolExpr(ts) else {return nil}
        guard let body = readProgram(ts) else {return nil}
        guard let t3 = ts.read() where t3.value == ")" else {return nil}
        return While(cond: cond, body: body)
    }
}

func readProgram(ts: TokenStream) -> Program? {
    if let x = readSequence(ts) {return x}
    if let x = readAssign(ts) {return x}
    if let x = readIf(ts) {return x}
    if let x = readWhile(ts) {return x}
    return nil
}

func parse(s: String) -> Program? {
    let tokenStream = TokenStream(tokens: tokenize(s))
    if let p = readProgram(tokenStream) {
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
