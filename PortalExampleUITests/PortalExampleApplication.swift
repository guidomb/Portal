//
//  PortalExampleApplication.swift
//  PortalExampleUITests
//
//  Created by Guido Marucci Blas on 6/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import XCTest

final class PortalExampleApplication {
    
    internal let app: XCUIApplication
    
    var mainScreen: MainScreenDriver {
        return MainScreenDriver(app: app)
    }
    
    var modalScreen: ModalScreenDriver {
        return ModalScreenDriver(app: app)
    }
    
    init(app: XCUIApplication = XCUIApplication()) {
        self.app = app
    }
    
    func launch() {
        app.launch()
    }
    
}


