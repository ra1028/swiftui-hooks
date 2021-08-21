<H1 align="center">
SwiftUI Hooks
</H1>

<p align="center">
A SwiftUI implementation of <a href="https://reactjs.org/docs/hooks-intro.html">React Hooks</a>.
</p>
<p align="center">
Enhances reusability of stateful logic and gives state and lifecycle to function view.
</p>

<p align="center">
<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"></a>
<a href="https://developer.apple.com"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C-green.svg"></a>
<a href="https://github.com/ra1028/SwiftUI-Hooks/actions"><img alt="GitHub Actions" src="https://github.com/ra1028/SwiftUI-Hooks/workflows/GitHub%20Actions/badge.svg"></a>
</p>

---

- [Introducing Hooks](#introducing-hooks)
- [Hooks API](#hooks-api)
- [Rules of Hooks](#rules-of-hooks)
- [Building Your Own Hooks](#building-your-own-hooks)
- [How to Test Your Custom Hooks](#how-to-test-your-custom-hooks)
- [Context](#context)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

---

## Introducing Hooks

```swift
func timer() -> some View {
    let time = useState(Date())

    useEffect(.once) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            time.wrappedValue = $0.fireDate
        }

        return {
            timer.invalidate()
        }
    }

    return Text("Time: \(time.wrappedValue)")
}
```

SwiftUI-Hooks is a SwiftUI implementation of React Hooks. Brings the state and lifecycle into the function view, without depending on elements that are only allowed to be used in struct views such as `@State` or `@ObservedObject`.  
It allows you to reuse stateful logic between views by building custom hooks composed with multiple hooks.  
Furthermore, hooks such as `useEffect` also solve the problem of lack of lifecycles in SwiftUI.  

The API and behavioral specs of SwiftUI-Hooks are entirely based on React Hooks, so you can leverage your knowledge of web applications to your advantage.  

There're already a bunch of documentations on React Hooks, so you can refer to it and learn more about Hooks.  

- [React Hooks Documentation](https://reactjs.org/docs/hooks-intro.html)  
- [Youtube Video](https://www.youtube.com/watch?v=dpw9EHDh2bM)  

---

## Hooks API

👇 Click to open the description.  

<details>
<summary><CODE>useState</CODE></summary>

```swift
func useState<State>(_ initialState: State) -> Binding<State>
```

A hook to use a `Binding<State>` wrapping current state to be updated by setting a new state to `wrappedValue`.  
Triggers a view update when the state has been changed.  

```swift
let count = useState(0)  // Binding<Int>

Button("Increment") {
    count.wrappedValue += 1
}
```

</details>

<details>
<summary><CODE>useEffect</CODE></summary>

```swift
func useEffect(_ updateStrategy: HookUpdateStrategy? = nil, _ effect: @escaping () -> (() -> Void)?)
```

A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.  
Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.  
Note that the execution is deferred until after ohter hooks have been updated.  

```swift
useEffect {
    print("Do side effects")

    return {
        print("Do cleanup")
    }
}
```

</details>

<details>
<summary><CODE>useLayoutEffect</CODE></summary>

```swift
func useLayoutEffect(_ updateStrategy: HookUpdateStrategy? = nil, _ effect: @escaping () -> (() -> Void)?)
```

A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.  
Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.  
The signature is identical to `useEffect`, but this fires synchronously when the hook is called.  

```swift
useLayoutEffect {
    print("Do side effects")
    return nil
}
```

</details>

<details>
<summary><CODE>useMemo</CODE></summary>

```swift
func useMemo<Value>(_ updateStrategy: HookUpdateStrategy, _ makeValue: @escaping () -> Value) -> Value
```

A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.  

```swift
let random = useMemo(.once) {
    Int.random(in: 0...100)
}
```

</details>

<details>
<summary><CODE>useRef</CODE></summary>

```swift
func useRef<T>(_ initialValue: T) -> RefObject<T>
```

A hook to use a mutable ref object storing an arbitrary value.  
The essential of this hook is that setting a value to `current` doesn't trigger a view update.  

```swift
let value = useRef("text")  // RefObject<String>

Button("Save text") {
    value.current = "new text"
}
```

</details>

<details>
<summary><CODE>useReducer</CODE></summary>

```swift
func useReducer<State, Action>(_ reducer: @escaping (State, Action) -> State, initialState: State) -> (state: State, dispatch: (Action) -> Void)
```

A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.  
Triggers a view update when the state has been changed.  

```swift
enum Action {
    case increment, decrement
}

func reducer(state: Int, action: Action) -> Int {
    switch action {
        case .increment:
            return state + 1

        case .decrement:
            return state - 1
    }
}

let (count, dispatch) = useReducer(reducer, initialState: 0)
```

</details>

<details>
<summary><CODE>useEnvironment</CODE></summary>

```swift
func useEnvironment<Value>(_ keyPath: KeyPath<EnvironmentValues, Value>) -> Value
```

A hook to use environment value passed through the view tree without `@Environment` property wrapper.  

```swift
let colorScheme = useEnvironment(\.colorScheme)  // ColorScheme
```

</details>

<details>
<summary><CODE>usePublisher</CODE></summary>

```swift
func usePublisher<P: Publisher>(_ updateStrategy: HookUpdateStrategy, _ makePublisher: @escaping () -> P) -> AsyncPhase<P.Output, P.Failure>
```

A hook to use the most recent phase of asynchronous operation of the passed publisher.  
The publisher will be subscribed at the first update and will be re-subscribed according to the given `updateStrategy`.  
Triggers a view update when the asynchronous phase has been changed.  

```swift
let phase = usePublisher(.once) {
    URLSession.shared.dataTaskPublisher(for: url)
}
```

</details>

<details>
<summary><CODE>usePublisherSubscribe</CODE></summary>

```swift
func usePublisherSubscribe<P: Publisher>(_ makePublisher: @escaping () -> P) -> (phase: AsyncPhase<P.Output, P.Failure>, subscribe: () -> Void)
```

A hook to use the most recent phase of asynchronous operation of the passed publisher, and a `subscribe` function to be started to subscribe arbitrary timing.  
Update the view with the asynchronous phase change.  

```swift
let (phase, subscribe) = usePublisherSubscribe {
    URLSession.shared.dataTaskPublisher(for: url)
}
```

</details>

<details>
<summary><CODE>useContext</CODE></summary>

```swift
func useContext<T>(_ context: Context<T>.Type) -> T
```

A hook to use current context value that is provided by `Context<T>.Provider`.  
The purpose is identical to use `Context<T>.Consumer`.  
See [Context](#context) section for more details.  

```swift
let value = useContext(Context<Int>.self)  // Int
```

</details>

See also: [React Hooks API Reference](https://reactjs.org/docs/hooks-reference.html)  

---

## Rules of Hooks

In order to take advantage of the wonderful interface of Hooks, the same rules that React hooks has must also be followed by SwiftUI Hooks.  

### Only Call Hooks at the Function Top Level

Do not call Hooks inside conditions or loops. The order in which hook is called is important since Hooks uses [LinkedList](https://en.wikipedia.org/wiki/Linked_list) to keep track of its state.  

🟢 **DO**

```swift
@ViewBuilder
var counterButton: some View {
    let count = useState(0)  // Uses hook at the top level

    Button("You clicked \(count.wrappedValue) times") {
        count.wrappedValue += 1
    }
}
```

🔴 **DON'T**

```swift
@ViewBuilder
var counterButton: some View {
    if condition {
        let count = useState(0)  // Uses hook inside condition.

        Button("You clicked \(count.wrappedValue) times") {
            count.wrappedValue += 1
        }
    }
}
```

### Only Call Hooks from `HookScope` or `HookView.hookBody`

In order to preserve the state, hooks must be called inside a `HookScope`.  
A view that conforms to the `HookView` protocol will automatically be enclosed in a `HookScope`.  

🟢 **DO**

```swift
struct ContentView: HookView {  // `HookView` is used.
    var hookBody: some View {
        let count = useState(0)

        Button("You clicked \(count.wrappedValue) times") {
            count.wrappedValue += 1
        }
    }
}
```

```swift
struct ContentView: View {
    var body: some View {
        HookScope {  // `HookScope` is used.
            let count = useState(0)

            Button("You clicked \(count.wrappedValue) times") {
                count.wrappedValue += 1
            }
        }
    }
}
```

🔴 **DON'T**

```swift
struct ContentView: View {
    var body: some View {  // Neither `HookScope` nor `HookView` is used.
        let count = useState(0)

        Button("You clicked \(count.wrappedValue) times") {
            count.wrappedValue += 1
        }
    }
}
```

See also: [Rules of React Hooks](https://reactjs.org/docs/hooks-rules.html)  

---

## Building Your Own Hooks

Building your own hooks lets you extract stateful logic into reusable functions.  
Hooks are composable since they serve as a stateful functions. So, they can be able to compose with other hooks to create your own custom hook.  

In the following example, the most basic `useState` and `useEffect` are used to make a function provides a current `Date` with the specified interval. If the specified interval is changed, `Timer.invalidate()` will be called and then a new timer will be activated.  
Like this, the stateful logic can be extracted out as a function using Hooks.  

```swift
func useTimer(interval: TimeInterval) -> Date {
    let time = useState(Date())

    useEffect(.preserved(by: interval)) {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            time.wrappedValue = $0.fireDate
        }

        return {
            timer.invalidate()
        }
    }

    return time.wrappedValue
}
```

Let's refactor the `Example` view at the beginning of the README using this custom hook.  

```swift
struct Example: HookView {
    var hookBody: some View {
        let time = useTimer(interval: 1)

        Text("Now: \(time)")
    }
}
```

It's so much easier to read and less codes!  
Of course the stateful custom hook can be called by arbitrary views.  

See also: [Building Your Own React Hooks](https://reactjs.org/docs/hooks-custom.html)  

---

## How to Test Your Custom Hooks

So far, we have explained that hooks should be called within `HookScope` or `HookView`. Then, how can the custom hook you have created be tested?  
To making unit testing of your custom hooks easy, SwiftUI-Hooks provides a simple and complete test utility library.  

`HookTester` enables unit testing independent of UI of custom hooks by simulating the behavior on the view of a given hook and managing the result values.  

Example:  

```swift
// Your custom hook.
func useCounter() -> (count: Int, increment: () -> Void) {
    let count = useState(0)

    let increment = {
        count.wrappedValue += 1
    }

    return (count: count.wrappedValue, increment: increment)
}
```

```swift
let tester = HookTester {
    useCounter()
}

XCTAssertEqual(tester.value.count, 0)

tester.value.increment()

XCTAssertEqual(tester.value.count, 1)

tester.update()  // Simulates view's update.

XCTAssertEqual(tester.value.count, 1)
```

---

## Context

React has a way to pass data through the component tree without having to pass it down manually, it's called `Context`.  
Similarly, SwiftUI has `EnvironmentValues` to achieve the same, but defining a custom environment value is a bit of a pain, so SwiftUI Hooks provides Context API that a more user-friendly.  
This is a simple wrapper around the `EnvironmentValues`.  

```swift
typealias ColorSchemeContext = Context<Binding<ColorScheme>>

struct ContentView: HookView {
    var hookBody: some View {
        let colorScheme = useState(ColorScheme.light)

        ColorSchemeContext.Provider(value: colorScheme) {
            darkModeButton
                .background(Color(.systemBackground))
                .colorScheme(colorScheme.wrappedValue)
        }
    }

    var darkModeButton: some View {
        ColorSchemeContext.Consumer { colorScheme in
            Button("Use dark mode") {
                colorScheme.wrappedValue = .dark
            }
        }
    }
}
```

And of course, there is a `useContext` hook that can be used instead of `Context.Consumer` to retrieve the provided value.  

```swift
@ViewBuilder
var darkModeButton: some View {
    let colorScheme = useContext(ColorSchemeContext.self)

    Button("Use dark mode") {
        colorScheme.wrappedValue = .dark
    }
}
```

See also: [React Context](https://reactjs.org/docs/context.html)  

---

## Requirements

- Swift 5.3+
- Xcode 12.4.0+
- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+

---

## Installation

### [Swift Package Manager for Apple Platforms](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

Xcode menu `File > Swift Packages > Add Package Dependency`.  

```text
Repository: https://github.com/ra1028/SwiftUI-Hooks
```

---

## Acknowledgements

- [React Hooks](https://reactjs.org/docs/hooks-intro.html)
- [Flutter Hooks](https://github.com/rrousselGit/flutter_hooks)

---

## License

[MIT © Ryo Aoyama](LICENSE)

---
