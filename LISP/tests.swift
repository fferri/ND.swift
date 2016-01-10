import Foundation

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

func runTests() {
    runTest("(set x 1)"){$0["x"] == 1}
    runTest("((set x 5) (set y 4) (set z 0)" +
        "(while (> y 0) ((set z (+ x z)) (set y (- y 1)))))"){$0["z"] == 20}
    runTest("(set x (+ 1 1 1 1 (- 10 5 3 2)))"){$0["x"] == 4}
    runTest(State(["x": 5]), "(if (> x 4) (set x 1))"){$0["x"] == 1}
    runTest(State(["x": 3]), "(if (> x 4) (set x 1))"){$0["x"] == 3}
}