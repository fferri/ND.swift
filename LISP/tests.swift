import Foundation

func runTokenizerTest(program: String, _ positions: [[Int]]) {
    let tokens = tokenize(program)
    for (token, position) in zip(tokens, positions) {
        if token.position.line != position[0] || token.position.column != position[1] {
            fatalError("failed tokenizer test for token \(token), expected position: \(position)")
        }
    }
}

func runTest(s0: State, _ program: String, test: (State -> Bool)) {
    if let p: Program = parse(program) {
        if !test(p.exec(s0)) {
            fatalError("test failed for \(program) (failed condition)")
        }
    } else {
        fatalError("test failed for \(program) (parse error)")
    }
}

func runTest(p: String, test t: (State -> Bool)) {
    return runTest(State(), p, test: t)
}

func runTest(p: String) {
    return runTest(p){_ in true}
}

func runTests() {
    runTest("((def printDouble (x) ((set y (* 2 x)) (print y))) (printDouble 2))")
    runTest("(set x 1)"){$0["x"] == 1}
    runTest("((set x 5) (set y 4) (set z 0)" +
        "(while (> y 0) ((set z (+ x z)) (set y (- y 1)))))"){$0["z"] == 20}
    runTest("(set z (* 5 4))"){$0["z"] == 20}
    runTest("(set z (/ 20 2 2))"){$0["z"] == 5}
    runTest("(set x (+ 1 1 1 1 (- 10 5 3 2)))"){$0["x"] == 4}
    runTest(State(["x": 5]), "(if (> x 4) (set x 1))"){$0["x"] == 1}
    runTest(State(["x": 3]), "(if (> x 4) (set x 1))"){$0["x"] == 3}
    runTokenizerTest("(set  x 1)\n(set y 2)", [[1,1],[1,2],[1,7],[1,9],[1,10],[2,1],[2,2],[2,6],[2,8],[2,9]])
}