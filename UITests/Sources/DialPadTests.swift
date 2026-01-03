import XCTest

@MainActor
class DialPadTests: XCTestCase {
    enum Step {
        static let startChat = 1
        static let dialPadEmpty = 2
        static let dialPadWithNumber = 3
        static let roomCreated = 4
    }
    
    func testDialPadFlow() async throws {
        let app = Application.launch(.startChatFlow)
        try await app.assertScreenshot(step: Step.startChat, testName: "dialPad")
        
        let dialButton = app.buttons["start_chat-dial_pad"]
        XCTAssertTrue(dialButton.waitForExistence(timeout: 5.0))
        dialButton.tap()
        
        let phoneDisplay = app.staticTexts[A11yIdentifiers.dialPadScreen.phoneNumberDisplay]
        XCTAssertTrue(phoneDisplay.waitForExistence(timeout: 5.0))
        try await app.assertScreenshot(step: Step.dialPadEmpty, testName: "dialPad")
        
        let digits = ["5", "5", "5", "1", "2", "3", "4", "5", "6", "7"]
        for digit in digits {
            let digitButton = app.buttons["\(A11yIdentifiers.dialPadScreen.digitButton)-\(digit)"]
            if digitButton.waitForExistence(timeout: 1.0) {
                digitButton.tap()
                try await Task.sleep(for: .milliseconds(200))
            }
        }
        
        try await app.assertScreenshot(step: Step.dialPadWithNumber, testName: "dialPad")
        
        let dialCallButton = app.buttons[A11yIdentifiers.dialPadScreen.dialButton]
        XCTAssertTrue(dialCallButton.waitForExistence(timeout: 2.0))
        dialCallButton.tap()
        
        try await Task.sleep(for: .seconds(3))
        try await app.assertScreenshot(step: Step.roomCreated, testName: "dialPad")
    }
}

