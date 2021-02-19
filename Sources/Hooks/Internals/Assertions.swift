import Foundation

internal func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "This API must be called only on the main thread.", file: file, line: line)
}

internal func fatalErrorHooksRules(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(
        """
        Hooks must be called at the function top level within scope of the HookScope or the HookView.hookBody`.

        - SeeAlso: https://reactjs.org/docs/hooks-rules.html
        """,
        file: file,
        line: line
    )
}
