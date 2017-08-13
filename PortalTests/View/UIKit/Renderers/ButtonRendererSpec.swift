//
//  ButtonRendererSpec.swift
//  Portal
//
//  Created by Guido Marucci Blas on 8/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class ButtonRendererSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: ButtonChangeSet, layoutEngine: LayoutEngine) -> Result") {
            
            var changeSet: ButtonChangeSet<String>!
            var buttonIcon: Image!
            
            beforeEach {
                buttonIcon = Image.loadImage(named: "search.png", from: Bundle(for: ButtonRendererSpec.self))
                
                let buttonProperties: ButtonProperties<String> = properties {
                    $0.text = "Hello World"
                    $0.isActive = true
                    $0.icon = buttonIcon
                    $0.onTap = "Tapped!"
                }
                
                let buttonStyle = buttonStyleSheet { base, button in
                    button.textColor = .red
                    button.textFont = Font(name: "Helvetica")
                    button.textSize = 12
                }
                
                changeSet = ButtonChangeSet.fullChangeSet(
                    properties: buttonProperties,
                    style: buttonStyle,
                    layout: layout()
                )
            }
            
            context("when the change set contains button property changes") {
                
                it("applies 'text' property changes") {
                    let button = UIButton()
                    _ = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(button.currentTitle).to(equal("Hello World"))
                }
                
                it("applies 'isActive' property changes") {
                    let button = UIButton()
                    _ = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(button.isSelected).to(beTrue())
                }
                
                it("applies 'icon' property changes") {
                    let button = UIButton()
                    _ = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(button.currentImage).to(equal(buttonIcon.asUIImage))
                }
                
                it("applies 'onTap' property changes") { waitUntil { done in
                    let button = UIButton()
                    let result = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("Tapped!"))
                        done()
                    }
                    
                    button.sendActions(for: .touchUpInside)
                }}
                
                context("when there are optional properties set to .none") {
                    
                    var configuredButton: UIButton!
                    
                    beforeEach {
                        configuredButton = UIButton()
                        _ = configuredButton.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("removes the button's title") {
                        let newChangeSet = ButtonChangeSet<String>(properties: [.text(.none)])
                        _ = configuredButton.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredButton.currentTitle).to(beNil())
                    }
                    
                    it("removes the button's icon") {
                        let newChangeSet = ButtonChangeSet<String>(properties: [.icon(.none)])
                        _ = configuredButton.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredButton.currentImage).to(beNil())
                    }
                    
                    it("removes the button's on tap handler") {
                        let newChangeSet = ButtonChangeSet<String>(properties: [.onTap(.none)])
                        let result = configuredButton.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        result.mailbox?.subscribe { _ in fail("On tap handler was not removed") }
                        
                        configuredButton.sendActions(for: .touchUpInside)
                    }
                    
                }
                
                context("when an on tap handler is already configured") {
                    
                    var configuredButton: UIButton!
                    
                    beforeEach {
                        configuredButton = UIButton()
                        _ = configuredButton.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous on tap handler") {
                        let newChangeSet = ButtonChangeSet<String>(properties: [.onTap("NewMessage!")])
                        let result = configuredButton.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredButton.sendActions(for: .touchUpInside)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("NewMessage!"))
                    }
                    
                }
                
            }
            
            context("when the change set contains button stylesheet changes") {
                
                it("applies 'textColor' property changes") {
                    let button = UIButton()
                    _ = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(button.titleLabel?.textColor).to(equal(.red))
                }
                
                it("applies 'textFont' and 'textSize' property changes") {
                    let button = UIButton()
                    _ = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(button.titleLabel?.font).to(equal(UIFont(name: "Helvetica", size: 12)))
                }
                
            }
            
        }
        
    }
}
