import XCTest

final class SampleAgentLoopUITests: XCTestCase {
    func testSignInScreenIsVisible() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Agent Loop"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["forgotPasswordLink"].exists)
    }
}
