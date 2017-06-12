//
//  MainScreenDriver.swift
//  PortalExampleUITests
//
//  Created by Guido Marucci Blas on 6/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import XCTest

final class MainScreenDriver {
    
    static func isVisible(app: XCUIApplication) -> Bool {
        return app.navigationBars["Root"].exists
    }
    
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var isVisible: Bool {
        return MainScreenDriver.isVisible(app: app)
    }
    
    func presentModalScreen() {
        app.buttons["Present modal"].tap()
    }
    
}
