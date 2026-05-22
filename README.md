# CANGJIE ECS FRAMEWORK 



### Shadow rule:
```
public class Box<T> {}
public class Mut<X> {}

extend<T> Box<T> {                       // (A) — для всех T
    public func each(cb: (T) -> Unit): Unit { ... }
}

extend<X> Box<Mut<X>> {                  // (B) — только когда T = Mut<X>
    public func each(cb: (Mut<X>) -> Unit): Unit { ... }
}
```

### Маркерный аргумент - НЕ ПОМОГЛО:
```
public class Tag<P> {}

extend<T> Box<T> {
    public func each(_: ?Tag<T> = None, cb: (T) -> Unit): Unit { ... }
}

extend<X> Box<Mut<X>> {
    public func each(_: ?Tag<Mut<X>> = None, cb: (Mut<X>) -> Unit): Unit { ... }
}
```


### Where-bound - НЕ ПОМОГЛО, оказывается, shadow rule проверяется компилятором до where bound:
```
public interface ComponentValue {}

extend<T> Box<T> where T <: ComponentValue {
    public func each(cb: (T) -> Unit): Unit { ... }
}

extend<X> Box<Mut<X>> where X <: ComponentValue {
    public func each(cb: (Mut<X>) -> Unit): Unit { ... }
}
```


```
public interface Handle<H> {
    static func makeHandle(box: Box<Self>): H
}

extend<X> Mut<X> <: Handle<Mut<X>> {
    public static func makeHandle(box: Box<Mut<X>>): Mut<X> {
        box.value
    }
}

extend Position <: Handle<Position> {
    public static func makeHandle(box: Box<Position>): Position {
        box.value
    }
}

// один extend на Box
extend<T> Box<T> where T <: Handle<T> {
    public func each(cb: (T) -> Unit): Unit {
        cb(T.makeHandle(this))
    }
}
```