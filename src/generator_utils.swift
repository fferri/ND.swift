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