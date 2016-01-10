import Foundation

struct Position : CustomStringConvertible {
    var line = 1
    var column = 0
    var description: String {return "line \(line) column \(column)"}
}

extension Position : ArrayLiteralConvertible {
    init(arrayLiteral elements: Int...) {
        if elements.count == 2 {
            line = elements[0]
            column = elements[1]
        } else {
            fatalError("too " + (elements.count > 2 ? "many" : "few") + " values to initialize Position")
        }
    }
}

extension Position : Equatable {}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.line == rhs.line && lhs.column == rhs.column
}

struct Token : CustomStringConvertible {
    var value = ""
    var position = Position()
    var length: Int {return value.characters.count}
    var description: String {return "\"\(value)\" at \(position)"}
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

/// A node is either: a compound, a number or a symbol
enum Node {
    case Comp(args: [Node], position: Position)
    case Symbol(name: String, position: Position)
    case Number(value: Int, position: Position)
}

/// Construct an atom (number or symbol) from a string
func makeAtom(token: Token) -> Node {
    if let i = Int(token.value) {
        return .Number(value: i, position: token.position)
    } else {
        return .Symbol(name: token.value, position: token.position)
    }
}

/// Read nodes from the token list. Returns the nodes and the residual tokens.
func readNodes(tokens: [Token], nest n: Int = 0) -> ([Node], [Token]) {
    var nodes = [Node]()
    var tokens1 = tokens
    var node: Node?
    while true {
        (node, tokens1) = readNode(tokens1, nest: n)
        if let node1 = node {nodes.append(node1)} else {break}
    }
    return (nodes, tokens1)
}

/// Read a node from the token list. Returns the node and the residual tokens.
func readNode(tokens: [Token], nest n: Int = 0) -> (Node?, [Token]) {
    if tokens.count == 0 {return (nil, [])}
    let (t, ts) = (tokens[0], Array(tokens[1..<tokens.count]))
    if t.value == "(" {
        let (nodes, tokens1) = readNodes(ts, nest: n + 1)
        if tokens1.count == 0 || tokens1[0].value != ")" {fatalError("missing \")\" at \(tokens1[0].position)")}
        return (.Comp(args: nodes, position: t.position), Array(tokens1[1..<tokens1.count]))
    } else if t.value == ")" {
        return (nil, tokens)
    } else {
        return (makeAtom(t), ts)
    }
}

/// Parse a list of S-expressions (separated by whitespace)
func parseSExprList(s: String) -> [Node] {
    let toks = tokenize(s)
    let (nodes, extraTokens) = readNodes(toks)
    if extraTokens.count > 0 {
        fatalError("unexpected \(extraTokens[0])")
    }
    return nodes
}

/// Parse a S-expressions
func parseSExpr(s: String) -> Node {
    let toks = tokenize(s)
    let (node, extraTokens) = readNode(toks)
    if extraTokens.count > 0 {
        fatalError("unexpected \(extraTokens[0])")
    }
    return node!
}

/// Translate a S-epression node into an Expr, or into nil if not possible
func translateExpr(n: Node) -> Expr? {
    switch n {
    case let .Number(value, _):
        return Expr.Const(x: value)
    case let .Comp(args, pos):
        let c = args.count
        if c > 0 {
            let ops = ["+", "-"]
            switch args[0] {
            case let .Symbol(op, _):
                if !ops.contains(op) {return nil}
                if c < 3 {
                    fatalError("at \(pos): not enough arguments for (\(op))")
                }
                var e1: Expr! = translateExpr(args[1])
                for i in 2..<c {
                    let e2: Expr! = translateExpr(args[i])
                    switch op {
                    case "+": e1 = Expr.Add(a: e1, b: e2)
                    case "-": e1 = Expr.Sub(a: e1, b: e2)
                    default: return nil
                    }
                }
                return e1
            default:
                return nil
            }
        } else {
            return nil
        }
    case let .Symbol(name, _):
        return Expr.Var(n: name)
    }
}

/// Translate a S-epression node into a BoolExpr, or into nil if not possible
func translateBoolExpr(n: Node) -> BoolExpr? {
    switch n {
    case let .Comp(args, pos):
        let c = args.count
        if c > 0 {
            let ops = ["and", "or", "not", "=", ">", "<"]
            switch args[0] {
            case let .Symbol(op, _):
                if !ops.contains(op) {return nil}
                switch op {
                case "not":
                    if c != 2 {fatalError("at \(pos): bad number of args for (\(op))")}
                    return BoolExpr.Not(e: translateBoolExpr(args[1])!)
                case "=":
                    if c != 3 {fatalError("at \(pos): bad number of args for (\(op))")}
                    return BoolExpr.Equal(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                case "<":
                    if c != 3 {fatalError("at \(pos): bad number of args for (\(op))")}
                    return BoolExpr.LessThan(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                case ">":
                    if c != 3 {fatalError("at \(pos): bad number of args for (\(op))")}
                    return BoolExpr.GreaterThan(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                default:
                    if c < 3 {
                        fatalError("at \(pos): not enough arguments for (\(op))")
                    }
                    var e1: BoolExpr! = translateBoolExpr(args[1])
                    for i in 2..<c {
                        let e2: BoolExpr! = translateBoolExpr(args[i])
                        switch args[0] {
                        case .Symbol("and", _): e1 = BoolExpr.And(a: e1, b: e2)
                        case .Symbol("or", _): e1 = BoolExpr.Or(a: e1, b: e2)
                        default: return nil
                        }
                    }
                    return e1
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    default:
        return nil
    }
}

/// Translate a S-epression node into a Program, or into nil if not possible
func translateProgram(n: Node) -> Program? {
    switch n {
    case let .Comp(args, pos):
        let c = args.count
        if c > 0 {
            switch args[0] {
            case let .Symbol(op, _):
                switch op {
                case "set":
                    if c != 3 {fatalError("at \(pos): \(op) has exactly 2 arguments")}
                    switch args[1] {
                    case let .Symbol(name, _):
                        let expr = translateExpr(args[2])
                        return Assign(name: name, value: expr!)
                    default:
                        fatalError("at \(pos): \(op)'s first argument is variable name")
                    }
                case "if":
                    if c != 3 {fatalError("at \(pos): \(op) has exactly 2 arguments. use (...) to group multiple statements")}
                    let cond = translateBoolExpr(args[1])
                    let body = translateProgram(args[2])
                    return If(cond: cond!, body: body!)
                case "while":
                    if c != 3 {fatalError("at \(pos): \(op) has exactly 2 arguments. use (...) to group multiple statements")}
                    let cond = translateBoolExpr(args[1])
                    let body = translateProgram(args[2])
                    return While(cond: cond!, body: body!)
                default:
                    return nil
                }
            case .Comp(_): // a sequence of statements
                if args.count < 2 {fatalError("at \(pos): unneeded (..)")}
                var seq = Sequence(p1: translateProgram(args[0])!, p2: translateProgram(args[1])!)
                for i in 2..<c {
                    seq = Sequence(p1: seq, p2: translateProgram(args[i])!)
                }
                return seq
            default:
                return nil
            }
        } else {
            return nil
        }
    default:
        return nil
    }
}

/// Parse a string into a program
func parse(s: String) -> Program? {
    return translateProgram(parseSExpr(s))
}
