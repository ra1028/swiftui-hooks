import XCTest

@testable import Todo

final class SimpleUITests: XCTestCase {
    func testInsertAndDelete() {
        let app = XCUIApplication()

        app.launch()

        let todoText = "TODO"
        let scrollViewElements = app.scrollViews.otherElements
        let inputField = scrollViewElements.textFields["input"]

        inputField.tap()

        for text in todoText {
            inputField.typeText(String(text))
            Thread.sleep(forTimeInterval: 0.1)
        }

        inputField.typeText(XCUIKeyboardKey.return.rawValue)

        let todo = scrollViewElements.staticTexts["todo:\(todoText)"]

        XCTAssertTrue(todo.exists)
        XCTAssertEqual(todo.label, todoText)

        let deleteButton = scrollViewElements.buttons["delete:\(todoText)"]

        deleteButton.tap()

        XCTAssertFalse(todo.exists)
    }
}
