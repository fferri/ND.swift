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
    guard let p: Program = parse(program) else {
        fatalError("syntax error")
    }
    guard let s = p.exec(s0) else {
        fatalError("program has no valid runs: \(p)")
    }
    if !test(s) {
        fatalError("test failed for \(p), s=\(s)")
    }
}

func runTest(p: String, test t: (State -> Bool)) {
    return runTest(State(), p, test: t)
}

func runTest(p: String) {
    return runTest(p){_ in true}
}

func runTests() {
    runTokenizerTest("(set  x 1)\n(set y 2)", [[1,1],[1,2],[1,7],[1,9],[1,10],[2,1],[2,2],[2,6],[2,8],[2,9]])

    runTest("(set x ())") {
        $0["x"]!.asList == ListValue.Nil
    }
    
    //runTest("((def printDouble (x) ((set y (* 2 x)) (print y))) (printDouble 2))")
    
    runTest("(set x 1)") {
        $0["x"]?.asInt == 1
    }
    
    runTest("((set x 5) (set y 4) (set z 0)" +
        "(while (> y 0) ((set z (+ x z)) (set y (- y 1)))))") {
            $0["z"]?.asInt == 20
    }
    
    runTest("(set z (* 5 4))") {
        $0["z"]?.asInt == 20
    }
    
    runTest("(set z (/ 20 2 2))") {
        $0["z"]?.asInt == 5
    }
    
    runTest("(set x (+ 1 1 1 1 (- 10 5 3 2)))") {
        $0["x"]?.asInt == 4
    }
    
    runTest(State(["x": .Integer(5)]), "(if (> x 4) (set x 1))") {
        $0["x"]?.asInt == 1
    }
    
    runTest(State(["x": .Integer(3)]), "(if (> x 4) (set x 1))") {
        $0["x"]?.asInt == 3
    }
    
    runTest("((domain x 1 2 3) (assert (= 4 (+ 2 x))))") {
        $0["x"]?.asInt == 2
    }
    
    runTest("((choose (set x 1) (set x 2)) (assert (= x 2)) (set y 2))") {
        $0["x"]?.asInt == 2 && $0["y"]?.asInt == 2
    }
    
    runTest("((choose (set x 1) (set x 2)) (set y 2))") {
        $0["x"]?.asInt == 1 && $0["y"]?.asInt == 2
    }
    
    runTest("((set x 1) (repeat (set x (+ x 1))) (assert (= x 4)))") {
        $0["x"]?.asInt == 4
    }
    
    runTest("((set x 1) (repeat (set x (+ x 1))) (assert (= x 1)))") {
        $0["x"]?.asInt == 1
    }
    
    // following test is tricky, because if the domain is infinite, it becomes undecidable
    // so we use a finite domain (x = 1..<10, y = 1..<10)
    runTest("((set x 1) (set y 1) (repeat (choose ((set x (+ x 1)) (assert (< x 10))) ((set y (+ y 1)) (assert (< y 10))))) (assert (= (* x y) 21)))") {
        $0["x"]!.asInt * $0["y"]!.asInt == 21
    }
    
    runTest("( (set x 3.14) (set y (* 2 x)) )") {
        $0["y"]?.asDouble == 6.28
    }
    
    runTest("((assert (or true false)) (assert (not (and true false))))")
    
    runTest("( (set s \"abc\") (set s1 (+ s \"d\")) )") {
        $0["s1"]?.asString == "abcd"
    }
    
    runTest("(set x (head (1 2 3 4)))") {
        $0["x"]?.asInt == 1
    }
    
    runTest("(set x (tail (1 2 3 4)))") {
        $0["x"]!.asList == ListValue.fromArray([2, 3, 4].map{Value.Integer($0)})
    }
    
    runTest("((set x ((+ 1 1) (* 2 3) (/ 6 2))) (set y (head (tail x))))") {
        $0["y"]?.asInt == 6
    }
    
    runTest("(set x (cons 1 ()))") {
        $0["x"]!.asList == ListValue.fromArray([Value.Integer(1)])
    }
    
    runTest("(assert (= () (tail (tail (1 2)))))")
    
    runTest("(assert (= (1 2 3) (cons 1 (cons 2 (cons 3 ())))))")
    
    runTest("(set x (len ()))") {
        $0["x"]?.asInt == 0
    }

    runTest("(set x (len (44)))") {
        $0["x"]?.asInt == 1
    }
    
    runTest("(set x (len (44 55 66)))") {
        $0["x"]?.asInt == 3
    }
    
    runTest("((set x (choose 1 2 3 4)) (set y (choose 7 4 1)) (assert (= 12 (* x y))))") {
        $0["x"]?.asInt == 3 && $0["y"]?.asInt == 4
    }
    
    runTest("((set x (1 2 3)) (set y (head (tail (tail x)))))") {
        $0["y"]?.asInt == 3
    }
    
    runTest("((set l ()) (repeat ((assert (< (len l) 4)) (set l (cons (choose 0 1) l)))) (assert (= (len l) 4)) (set z (+ (head l) (head (tail l)) (head (tail (tail l))) (head (tail (tail (tail l)))))) (assert (= z 2)) (assert (= (head l) 0)))") {
        s in
        let l = s["l"]!.asList.toArray.map{x in x.asInt}
        return l == [0, 1, 1, 0] || l == [0, 1, 0, 1] || l == [0, 0, 1, 1]
    }
    
    print("all tests passed successfully")
}