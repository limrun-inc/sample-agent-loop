import XCTest

final class SampleAgentLoopUITests: XCTestCase {
    func testGreetingIsVisible() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Hello, world!"].waitForExistence(timeout: 10))
    }
}
