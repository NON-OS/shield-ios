import XCTest

/// Every screen a new holder reaches, in order, with a screenshot of each kept in the result
/// bundle and Xcode's accessibility audit run on it. It makes a fresh simulator wallet and reads
/// nothing from the pool. A second walk, at the largest text, is in ScreensLargeText.swift.
final class ScreensTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        // The single time question iOS asks before an app may use Face ID.
        addUIInterruptionMonitor(withDescription: "Face ID") { alert in
            for label in ["OK", "Allow"] where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
    }

    func testEveryScreen() {
        app.launch()
        shot("01 Welcome")
        tap("Create a wallet")
        XCTAssertTrue(app.buttons["I have written them down"].waitForExistence(timeout: 60))
        shot("02 Recovery phrase")
        tap("I have written them down")
        XCTAssertTrue(app.buttons["Shield"].waitForExistence(timeout: 60))
        shot("03 Wallet")
        for (index, name) in ["Receive", "Swap", "Shield", "Settings"].enumerated() {
            visit(name, as: "0\(index + 4) \(name)")
        }
    }

    /// Open a panel from the balance screen, keep it, and come back.
    func visit(_ name: String, as label: String) {
        tap(name)
        sleep(2)
        shot(label)
        app.swipeUp()
        shot(label + " (lower)")
        // Back until home is up. On Sepolia, Receive opens the private side, one level under the
        // shield, so one Back left the walk on the shield, looking for Swap.
        for _ in 0..<3 where !app.buttons["Swap"].exists && app.buttons["Back"].exists {
            app.buttons["Back"].tap()
            _ = app.buttons["Swap"].waitForExistence(timeout: 5)
        }
    }

    func tap(_ name: String) {
        let button = app.buttons[name]
        XCTAssertTrue(button.waitForExistence(timeout: 30), "no button \(name)")
        for _ in 0..<3 where !button.isHittable {
            app.swipeUp()
        }
        button.tap()
        // Lets the interruption monitor answer a system prompt, if one came up.
        app.tap()
    }

    func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        audit(name)
    }
}
