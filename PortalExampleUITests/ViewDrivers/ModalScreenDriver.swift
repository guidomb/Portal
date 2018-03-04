//
//  ModalScreenDriver.swift
//  PortalExampleUITests
//
//  Created by Guido Marucci Blas on 6/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import XCTest

final class ModalScreenDriver {
    
    static func isVisible(app: XCUIApplication) -> Bool {
        return app.navigationBars["Modal"].exists
    }
    
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var isVisible: Bool {
        return ModalScreenDriver.isVisible(app: app)
    }
    
    var counterLabelText: String {
        let predicate = NSPredicate(format: "label BEGINSWITH 'Counter'")
        return app.staticTexts.matching(predicate).firstMatch.label
    }
    
    var currentCounterValue: UInt {
        return matchGroups(in: counterLabelText, with: "Counter ([0-9]+)")
            .first
            .flatMap { UInt($0) } ?? 0
    }
    
    func closeModal() {
        app.buttons["Close"].tap()
    }
    
    func incrementCounter() {
        app.buttons["Increment!"].tap()
    }
    
    func waitForCounterToFinishUpdating(timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) {
        let counterFinishedUpdating = app.staticTexts["Counter 5"].waitForExistence(timeout: timeout)
        XCTAssertTrue(counterFinishedUpdating, "Counter did not finish updating", file: file, line: line)
    }
    
    
}

private func matchGroups(in string: String, with regexpString: String) -> [String] {
    let stringRange = NSMakeRange(0, string.count)
    guard   let regexp = try? NSRegularExpression(pattern: regexpString, options: []),
            let result = regexp.firstMatch(in: string, options: [], range: stringRange) else { return [] }
    
    var extractedMatches: [String] = []
    for index in (1..<result.numberOfRanges) {
        if let range = Range(result.range(at: index), in: string) {
            extractedMatches.append(String(string[range]))
        }
    }
    
    return extractedMatches
}
