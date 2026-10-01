import XCTest

/// The same screens at the largest accessibility text size, on the wallet the first walk made, and
/// the audit that each screenshot runs. XCTest runs this after testEveryScreen, by name.
extension ScreensTests {
    func testEveryScreenAtTheLargestText() {
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()
        tap("Unlock")
        XCTAssertTrue(app.buttons["Shield"].waitForExistence(timeout: 60))
        shot("10 Wallet, largest text")
        for (index, name) in ["Receive", "Swap", "Shield", "Settings"].enumerated() {
            visit(name, as: "1\(index + 1) \(name), largest text")
        }
    }

    /// Xcode's accessibility audit of what is on screen: labels, contrast, hit areas, text that
    /// does not scale or is clipped. Each issue is kept beside the screenshots as text, naming the
    /// element, and fails the test so the run says how many there were.
    func audit(_ name: String) {
        do {
            try app.performAccessibilityAudit { issue in
                let attachment = XCTAttachment(string: [
                    issue.compactDescription,
                    issue.detailedDescription,
                    issue.element.map { String(describing: $0) } ?? "no element"
                ].joined(separator: "\n"))
                attachment.name = "\(name), audit"
                attachment.lifetime = .keepAlways
                self.add(attachment)
                return false
            }
        } catch {
            XCTFail("\(name): the audit did not run: \(error)")
        }
    }
}
