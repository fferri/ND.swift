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

extension Const {
    static func readConst(ts: TokenStream) -> AlgebraicExpr? {
        if let i = AlgebraicExpr.readIntAtom(ts) {
            return Const(i)
        }
        return nil
    }
}

extension Var {
    static func readVar(ts: TokenStream) -> AlgebraicExpr? {
        if let s = AlgebraicExpr.readStringAtom(ts) {
            return Var(s)
        }
        return nil
    }
}

extension Add {
    static func readAdd(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicExpr.readOp(ts, op: "+") else {return nil}
        var e = Add(o[0], o[1])
        for i in 2..<o.count {
            e = Add(e, o[i])
        }
        return e
    }
}

extension Sub {
    static func readSub(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicExpr.readOp(ts, op: "-") else {return nil}
        var e = Sub(o[0], o[1])
        for i in 2..<o.count {
            e = Sub(e, o[i])
        }
        return e
    }
}

extension Mul {
    static func readMul(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicExpr.readOp(ts, op: "*") else {return nil}
        var e = Mul(o[0], o[1])
        for i in 2..<o.count {
            e = Mul(e, o[i])
        }
        return e
    }
}

extension Div {
    static func readDiv(ts: TokenStream) -> AlgebraicExpr? {
        guard let o = AlgebraicExpr.readOp(ts, op: "/") else {return nil}
        var e = Div(o[0], o[1])
        for i in 2..<o.count {
            e = Div(e, o[i])
        }
        return e
    }
}

extension AlgebraicExpr {
    static func readIntAtom(ts: TokenStream) -> Int? {
        return ts.t{_ in
            if let t = ts.read() {
                if let i = Int(t.value) {
                    return i
                }
            }
            return nil
        }
    }
    
    static func readStringAtom(ts: TokenStream) -> String? {
        return ts.t{_ in
            if let t = ts.read() {
                if t.isSymbol {
                    return t.value
                }
            }
            return nil
        }
    }
    
    static func readOp(ts: TokenStream, op: String) -> [AlgebraicExpr]? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            var e = [AlgebraicExpr]()
            while let en = AlgebraicExpr.readAlgebraicExpr(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return e.count >= 2 ? e : nil
        }
    }
    
    static func readAlgebraicExpr(ts: TokenStream) -> AlgebraicExpr? {
        if let x = Const.readConst(ts) {return x}
        if let x = Var.readVar(ts) {return x}
        if let x = Add.readAdd(ts) {return x}
        if let x = Sub.readSub(ts) {return x}
        if let x = Mul.readMul(ts) {return x}
        if let x = Div.readDiv(ts) {return x}
        return nil
    }
}

extension And {
    static func readAnd(ts: TokenStream) -> BoolExpr? {
        guard let o = BoolExpr.readOp(ts, op: "and") else {return nil}
        var e = And(o[0], o[1])
        for i in 2..<o.count {
            e = And(e, o[i])
        }
        return e
    }
}

extension Or {
    static func readOr(ts: TokenStream) -> BoolExpr? {
        guard let o = BoolExpr.readOp(ts, op: "or") else {return nil}
        var e = Or(o[0], o[1])
        for i in 2..<o.count {
            e = Or(e, o[i])
        }
        return e
    }
}

extension Not {
    static func readNot(ts: TokenStream) -> BoolExpr? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "not" else {return nil}
            guard let e1 = BoolExpr.readBoolExpr(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return Not(e1)
        }
    }
}

extension LessThan {
    static func readLessThan(ts: TokenStream) -> BoolExpr? {
        guard let (e1, e2) = BoolExpr.readRelOp(ts, op: "<") else {return nil}
        return LessThan(e1, e2)
    }
}

extension Equal {
    static func readEqual(ts: TokenStream) -> BoolExpr? {
        guard let (e1, e2) = BoolExpr.readRelOp(ts, op: "=") else {return nil}
        return Equal(e1, e2)
    }
}

extension GreaterThan {
    static func readGreaterThan(ts: TokenStream) -> BoolExpr? {
        guard let (e1, e2) = BoolExpr.readRelOp(ts, op: ">") else {return nil}
        return GreaterThan(e1, e2)
    }
}

extension BoolExpr {
    static func readRelOp(ts: TokenStream, op: String) -> (AlgebraicExpr, AlgebraicExpr)? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            guard let e1 = AlgebraicExpr.readAlgebraicExpr(ts) else {return nil}
            guard let e2 = AlgebraicExpr.readAlgebraicExpr(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return (e1, e2)
        }
    }
    
    static func readOp(ts: TokenStream, op: String) -> [BoolExpr]? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == op else {return nil}
            var e = [BoolExpr]()
            while let en = BoolExpr.readBoolExpr(ts) {
                e.append(en)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return e.count >= 2 ? e : nil
        }
    }
    
    static func readBoolExpr(ts: TokenStream) -> BoolExpr? {
        if let x = And.readAnd(ts) {return x}
        if let x = Or.readOr(ts) {return x}
        if let x = Not.readNot(ts) {return x}
        if let x = LessThan.readLessThan(ts) {return x}
        if let x = Equal.readEqual(ts) {return x}
        if let x = GreaterThan.readGreaterThan(ts) {return x}
        return nil
    }
}

extension Sequence {
    static func readSequence(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let p1 = Program.readProgram(ts) else {return nil}
            guard let p2 = Program.readProgram(ts) else {return nil}
            var p = Sequence(p1, p2)
            while let pn = Program.readProgram(ts) {
                p = Sequence(p, pn)
            }
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return p
        }
    }
}

extension Assign {
    static func readAssign(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "set" else {return nil}
            guard let name = AlgebraicExpr.readStringAtom(ts) else {return nil}
            guard let value = AlgebraicExpr.readAlgebraicExpr(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return Assign(name, value)
        }
    }
}

extension If {
    static func readIf(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "if" else {return nil}
            guard let cond = BoolExpr.readBoolExpr(ts) else {return nil}
            guard let body = Program.readProgram(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return If(cond, body)
        }
    }
}

extension While {
    static func readWhile(ts: TokenStream) -> Program? {
        return ts.t{_ in
            guard let t1 = ts.read() where t1.value == "(" else {return nil}
            guard let t2 = ts.read() where t2.value == "while" else {return nil}
            guard let cond = BoolExpr.readBoolExpr(ts) else {return nil}
            guard let body = Program.readProgram(ts) else {return nil}
            guard let t3 = ts.read() where t3.value == ")" else {return nil}
            return While(cond, body)
        }
    }
}

extension Program {
    static func readProgram(ts: TokenStream) -> Program? {
        if let x = Sequence.readSequence(ts) {return x}
        if let x = Assign.readAssign(ts) {return x}
        if let x = If.readIf(ts) {return x}
        if let x = While.readWhile(ts) {return x}
        return nil
    }
}

func parse(s: String) -> Program? {
    let tokenStream = TokenStream(tokens: tokenize(s))
    if let p = Program.readProgram(tokenStream) {
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
