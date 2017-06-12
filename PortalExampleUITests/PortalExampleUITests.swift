//
//  PortalExampleUITests.swift
//  PortalExampleUITests
//
//  Created by Guido Marucci Blas on 6/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import XCTest

class PortalExampleUITests: XCTestCase {
    
    var app: PortalExampleApplication!
    
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = PortalExampleApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        
        app = nil
    }
    
    func testPresentAndCloseModalScreen() {
        
        let mainScreen = app.mainScreen
        XCTContext.runActivity(named: "Present modal screen") { _ in
            XCTAssertTrue(mainScreen.isVisible)
            mainScreen.presentModalScreen()
        }
        
        let modalScreen = app.modalScreen
        XCTContext.runActivity(named: "Close modal screen") { _ in
            XCTAssertTrue(modalScreen.isVisible)
            modalScreen.closeModal()
        }
        
        XCTAssertTrue(mainScreen.isVisible)
        
    }
    
    func testPresentModalAndWaitForCounterCompletion() {
        
        let mainScreen = app.mainScreen
        XCTContext.runActivity(named: "Present modal screen") { _ in
            XCTAssertTrue(mainScreen.isVisible)
            mainScreen.presentModalScreen()
        }
        
        let modalScreen = app.modalScreen
        XCTContext.runActivity(named: "Wait for counter to complete updating") { _ in
            modalScreen.waitForCounterToFinishUpdating()
        }
        
    }
    
    func testPresentModalThenWaitForCounterCompletionAndIncrement() {
        
        let mainScreen = app.mainScreen
        XCTContext.runActivity(named: "Present modal screen") { _ in
            XCTAssertTrue(mainScreen.isVisible)
            mainScreen.presentModalScreen()
        }
        
        let modalScreen = app.modalScreen
        XCTContext.runActivity(named: "Wait for counter to complete updating") { _ in
            modalScreen.waitForCounterToFinishUpdating()
        }
        
        XCTContext.runActivity(named: "Increment counter") { _ in
            let counterValueBeforeIncrement = modalScreen.currentCounterValue
            modalScreen.incrementCounter()
            XCTAssertEqual(counterValueBeforeIncrement + 1, modalScreen.currentCounterValue)
        }
        
    }
    
}
