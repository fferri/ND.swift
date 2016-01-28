import Foundation

func emptyGenerator<T>() -> AnyGenerator<T> {
    return anyGenerator{
        return nil
    }
}

func generateOnce<T>(g: () -> T) -> AnyGenerator<T> {
    var first = true
    return anyGenerator{
        if first {
            first = false
            return g()
        } else {
            return nil
        }
    }
}

func generatorProduct<T1, T2>(g1: AnyGenerator<T1>, _ g2: AnyGenerator<T2>) -> AnyGenerator<(T1, T2)> {
    var a1 = [T1](), a2 = [T2]()
    var p = 0
    var lastPick = 2
    
    return anyGenerator{
        if a1.isEmpty && a2.isEmpty {
            if let x1 = g1.next() {
                a1.append(x1)
                if let x2 = g2.next() {
                    a2.append(x2)
                    p = 1
                    return (x1, x2)
                }
            }
        }
        
        if lastPick == 1 && p >= a2.count {
            if let x2 = g2.next() {
                a2.append(x2)
                lastPick = 2
                p = 0
            } else if let x1 = g1.next() {
                a1.append(x1)
                lastPick = 1
                p = 0
            } else {
                return nil
            }
        } else if lastPick == 2 && p >= a1.count {
            if let x1 = g1.next() {
                a1.append(x1)
                lastPick = 1
                p = 0
            } else if let x2 = g2.next() {
                a2.append(x2)
                lastPick = 2
                p = 0
            } else {
                return nil
            }
        }
        
        if lastPick == 1 {
            let ret = (a1[a1.count - 1], a2[p])
            p += 1
            return ret
        } else if lastPick == 2 {
            let ret = (a1[p], a2[a2.count - 1])
            p += 1
            return ret
        } else {
            fatalError()
        }
    }
}

func generatorProduct<T>(g: [AnyGenerator<T>], offset o: Int = 0) -> AnyGenerator<[T]> {
    if g.isEmpty {
        return emptyGenerator()
    }
    if o == g.count - 1 {
        return transformGenerator(g[o]) {x in [x]}
    }
    return transformGenerator(generatorProduct(g[o], generatorProduct(g, offset: o + 1))) {
        x, y in [x] + y
    }
}

func transformGenerator<T1, T2>(g: AnyGenerator<T1>, f: T1 -> T2) -> AnyGenerator<T2> {
    return anyGenerator{
        if let x = g.next() {
            return f(x)
        } else {
            return nil
        }
    }
}

func generateTransformedProduct<T1, T2, T3>(g1: AnyGenerator<T1>, _ g2: AnyGenerator<T2>, _ f: (T1, T2) -> T3) -> AnyGenerator<T3> {
    return transformGenerator(generatorProduct(g1, g2), f: f)
}

func chainGenerators<T>(g1: AnyGenerator<T>, _ g2: AnyGenerator<T>) -> AnyGenerator<T> {
    return anyGenerator{
        return g1.next() ?? g2.next()
    }
}

func chainGenerators<T>(g: [AnyGenerator<T>], offset o: Int = 0) -> AnyGenerator<T> {
    if g.isEmpty {
        return emptyGenerator()
    }
    if o == g.count - 1 {
        return g[o]
    }
    return chainGenerators(g[o], chainGenerators(g, offset: o + 1))
}

func chainGenerators<T>(gg: AnyGenerator<AnyGenerator<T>>) -> AnyGenerator<T> {
    var g = gg.next()
    return anyGenerator{
        if g == nil {return nil}
        if let ret = g!.next() {
            return ret
        } else {
            g = gg.next()
            return g == nil ? nil : g!.next()
        }
    }
}

func any<T>(g: AnyGenerator<T>, predicate: T -> Bool) -> Bool {
    for x in g {
        if predicate(x) {
            return true
        }
    }
    return false
}

func all<T>(g: AnyGenerator<T>, predicate: T -> Bool) -> Bool {
    for x in g {
        if !predicate(x) {
            return false
        }
    }
    return true
}
