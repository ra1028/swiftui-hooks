# ``Hooks``

🪝 A SwiftUI implementation of React Hooks. Enhances reusability of stateful logic and gives state and lifecycle to function view.

## Overview

SwiftUI Hooks is a SwiftUI implementation of React Hooks. Brings the state and lifecycle into the function view, without depending on elements that are only allowed to be used in struct views such as @State or @ObservedObject.
It allows you to reuse stateful logic between views by building custom hooks composed with multiple hooks.
Furthermore, hooks such as useEffect also solve the problem of lack of lifecycles in SwiftUI.

## Source Code

<https://github.com/ra1028/swiftui-hooks>

## Topics

### Hooks

- ``useState(_:)``
- ``useEffect(_:_:)``
- ``useLayoutEffect(_:_:)``
- ``useMemo(_:_:)``
- ``useRef(_:)``
- ``useReducer(_:initialState:)``
- ``useEnvironment(_:)``
- ``usePublisher(_:_:)``
- ``usePublisherSubscribe(_:)``
- ``useContext(_:)``

### User Interface

- ``HookScope``
- ``HookView``

### Values

- ``Context``
- ``AsyncPhase``
- ``RefObject``
- ``HookUpdateStrategy``

### Testing

- ``HookTester``

### Internal System

- ``useHook(_:)``
- ``Hook``
- ``HookCoordinator``
- ``HookDispatcher``
