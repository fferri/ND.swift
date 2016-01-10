import Foundation

/// Tokenize, i.e. convert a string into an array of strings (tokens)
func tokenize(s: String) -> [String] {
    var tokens = [String]()
    var token = "" as String
    var str = false
    var esc = false
    for c in s.characters {
        if esc {
            token.append(c)
            esc = false
        } else if !str && (c == " " || c == "\n" || c == "\t" || c == "(" || c == ")") {
            if token.characters.count > 0 {
                tokens.append(token)
                token = ""
            }
            if c == "(" || c == ")" {
                tokens.append(String(c))
            }
        } else if str && c == "\\" {
            esc = true
        } else if c == "\"" {
            str = !str
        } else {
            token.append(c)
        }
    }
    if token.characters.count > 0 {tokens.append(token)}
    return tokens
}

/// A node is either: a compound, a number or a symbol
enum Node : CustomStringConvertible {
    case Comp(args: [Node])
    case Symbol(name: String)
    case Number(value: Int)
    var description: String {
        switch(self) {
        case Comp(let a): return "\(a)"
        case Symbol(let a): return "\"\(a)\""
        case Number(let a): return "\(a)"
        }
    }
}

/// Construct an atom (number or symbol) from a string
func makeAtom(s: String?) -> Node? {
    if s == nil {return nil}
    if let i = Int(s!) {return .Number(value: i)} else {return .Symbol(name: s!)}
}

/// Read noded from the token list. Returns the nodes and the residual tokens.
func readNodes(tokens: [String], nest n: Int = 0) -> ([Node], [String]) {
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
func readNode(tokens: [String], nest n: Int = 0) -> (Node?, [String]) {
    if tokens.count == 0 {return (nil, [])}
    let (t, ts) = (tokens[0], Array(tokens[1..<tokens.count]))
    if t == "(" {
        let (nodes, tokens1) = readNodes(ts, nest: n + 1)
        if tokens1.count == 0 || tokens1[0] != ")" {fatalError("missing )")}
        return (.Comp(args: nodes), Array(tokens1[1..<tokens1.count]))
    } else if t == ")" {
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
    case let .Number(value):
        return Expr.Const(x: value)
    case let .Comp(args):
        let c = args.count
        if c > 0 {
            let ops = ["+", "-"]
            switch args[0] {
            case let .Symbol(op):
                if !ops.contains(op) {return nil}
                if c < 3 {
                    fatalError("not enough arguments for (\(op))")
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
    case let .Symbol(name):
        return Expr.Var(n: name)
    }
}

/// Translate a S-epression node into a BoolExpr, or into nil if not possible
func translateBoolExpr(n: Node) -> BoolExpr? {
    switch n {
    case let .Comp(args):
        let c = args.count
        if c > 0 {
            let ops = ["and", "or", "not", "=", ">", "<"]
            switch args[0] {
            case let .Symbol(op):
                if !ops.contains(op) {return nil}
                switch op {
                case "not":
                    if c != 2 {fatalError("bad number of args for (\(op))")}
                    return BoolExpr.Not(e: translateBoolExpr(args[1])!)
                case "=":
                    if c != 3 {fatalError("bad number of args for (\(op))")}
                    return BoolExpr.Equal(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                case "<":
                    if c != 3 {fatalError("bad number of args for (\(op))")}
                    return BoolExpr.LessThan(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                case ">":
                    if c != 3 {fatalError("bad number of args for (\(op))")}
                    return BoolExpr.GreaterThan(a: translateExpr(args[1])!, b: translateExpr(args[2])!)
                default:
                    if c < 3 {
                        fatalError("not enough arguments for (\(op))")
                    }
                    var e1: BoolExpr! = translateBoolExpr(args[1])
                    for i in 2..<c {
                        let e2: BoolExpr! = translateBoolExpr(args[i])
                        switch args[0] {
                        case .Symbol("and"): e1 = BoolExpr.And(a: e1, b: e2)
                        case .Symbol("or"): e1 = BoolExpr.Or(a: e1, b: e2)
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
    case let .Comp(args):
        let c = args.count
        if c > 0 {
            switch args[0] {
            case let .Symbol(op):
                switch op {
                case "set":
                    if c != 3 {fatalError("\(op) has exactly 2 arguments")}
                    switch args[1] {
                    case let .Symbol(name):
                        let expr = translateExpr(args[2])
                        return Assign(name: name, value: expr!)
                    default:
                        fatalError("\(op)'s first argument is variable name")
                    }
                case "if":
                    if c != 3 {fatalError("\(op) has exactly 2 arguments. use (...) to group multiple statements")}
                    let cond = translateBoolExpr(args[1])
                    let body = translateProgram(args[2])
                    return If(cond: cond!, body: body!)
                case "while":
                    if c != 3 {fatalError("\(op) has exactly 2 arguments. use (...) to group multiple statements")}
                    let cond = translateBoolExpr(args[1])
                    let body = translateProgram(args[2])
                    return While(cond: cond!, body: body!)
                default:
                    return nil
                }
            case .Comp(_):
                if args.count < 2 {fatalError("unneeded (..)")}
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
