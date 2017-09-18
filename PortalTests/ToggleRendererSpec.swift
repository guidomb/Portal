//
//  ToggleRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class ToggleRendererSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: ToggleChangeSet, layoutEngine: LayoutEngine) -> Result") {
            
            var changeSet: ToggleChangeSet<String>!
            
            beforeEach {
                let style = toggleStyleSheet { base, toggle in
                    toggle.onTintColor = .red
                    toggle.tintChangingColor = .blue
                    toggle.thumbTintColor = .green
                }
                
                let toogleProperties: ToggleProperties<String> = properties {
                    $0.isOn = true
                    $0.isActive = true
                    $0.isEnabled = true
                    $0.onSwitch = {
                        if $0 {
                            return "onSwitchTrue"
                        } else {
                            return "onSwitchFalse"
                        }
                    }
                }
                
                changeSet = ToggleChangeSet.fullChangeSet(
                    properties: toogleProperties,
                    style: style,
                    layout: layout())
            }
            
            context("when the change set contains toggle property changes") {
                
                it("applies 'isOn' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.isOn).to(beTrue())
                }
                
                it("applies 'isActive' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.isSelected).to(beTrue())
                }
                
                it("applies 'isEnabled' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.isEnabled).to(beTrue())
                }
                
                it("applies 'onSwitch' property changes") { waitUntil { done in
                    let toggle = UISwitch()
                    let result = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("onSwitchTrue"))
                        done()
                    }
                    
                    toggle.sendActions(for: .touchUpInside)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("onSwitchTrue"))
                        done()
                    }
                }}
            
                context("when an onSwitch handler is already configured") {
                    
                    var configuredToggle: UISwitch!
                    
                    beforeEach {
                        configuredToggle = UISwitch()
                        _ = configuredToggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous onSwitch handler") {
                        let newChangeSet = ToggleChangeSet<String>(properties: [.onSwitch({ _ in return "newMessage"})])
                        let result = configuredToggle.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredToggle.sendActions(for: .touchUpInside)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("newMessage"))
                    }
                    
                }
                
            }
         
            context("when the change set contains toggle stylesheet changes") {
                
                it("applies 'onTintColor' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.onTintColor).to(equal(.red))
                }
            
                it("applies 'tintChangingColor' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.tintColor).to(equal(.blue))
                }
                
                it("applies 'thumbTintColor' property changes") {
                    let toggle = UISwitch()
                    _ = toggle.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(toggle.thumbTintColor).to(equal(.green))
                }
                
            }
            
        }
        
    }
}
