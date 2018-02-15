//
//  TextFieldRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 8/24/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class TextFieldRendererSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: TextFieldChangeSet) -> Result") {
            
            var changeSet: TextFieldChangeSet<String>!
            
            beforeEach {
                let textFieldProperties: TextFieldProperties<String> = properties {
                    $0.text = "Hello World"
                    $0.placeholder = "Placeholder"
                    $0.onEvents = textFieldEvents {
                        $0.onEditingBegin = { text in "onEditingBegin: \(text)" }
                        $0.onEditingChanged = { text in "onEditingChanged: \(text)" }
                        $0.onEditingEnd = { text in "onEditingEnd: \(text)" }
                    }
                }
                
                let textFieldStyle = textFieldStyleSheet { base, textField in
                    textField.textColor = .red
                    textField.textFont = Font(name: "Helvetica")
                    textField.textSize = 12
                    textField.textAlignment = .center
                }
                
                changeSet = TextFieldChangeSet.fullChangeSet(
                    properties: textFieldProperties,
                    style: textFieldStyle,
                    layout: layout())
            }
            
            context("when the change set contains textField property changes") {
                
                it("applies 'text' property changes") {
                    let textField = UITextField()
                    _ = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textField.text).to(equal("Hello World"))
                }
                
                it("applies 'placeholder' property changes") {
                    let textField = UITextField()
                    _ = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textField.placeholder).to(equal("Placeholder"))
                }
                
                it("applies 'onEvents.onEditingBegin' property changes") { waitUntil { done in
                    let textField = UITextField()
                    let result = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("onEditingBegin: Hello World"))
                        done()
                    }
                    
                    textField.sendActions(for: .editingDidBegin)
                }}
                
                it("applies 'onEvents.onEditingChanged' property changes") { waitUntil { done in
                    let textField = UITextField()
                    let result = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("onEditingChanged: Hello World"))
                        done()
                    }
                    
                    textField.sendActions(for: .editingChanged)
                }}
                
                it("applies 'onEvents.onEditingEnd' property changes") { waitUntil { done in
                    let textField = UITextField()
                    let result = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe { message in
                        expect(message).to(equal("onEditingEnd: Hello World"))
                        done()
                    }
                    
                    textField.sendActions(for: .editingDidEnd)
                }}
                
                context("when there are optional properties set to .none") {
                
                    var configuredTextField: UITextField!
                    
                    beforeEach {
                        configuredTextField = UITextField()
                        _ = configuredTextField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("removes the textField's text") {
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.text(.none)])
                        _ = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredTextField.text).to(equal(""))
                    }
                    
                    it("removes the textField's placeholder") {
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.placeholder(.none)])
                        _ = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredTextField.placeholder).to(beNil())
                    }
                    
                    it("removes the textField's onEvents handler") {
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.onEvents(textFieldEvents())])
                        let result = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        result.mailbox?.subscribe { _ in fail("On editing handler was not removed") }
                        
                        configuredTextField.sendActions(for: .editingDidBegin)
                        configuredTextField.sendActions(for: .editingChanged)
                        configuredTextField.sendActions(for: .editingDidEnd)
                    }
                    
                }
                
                context("when an onEvents handler is already configured") {
                    
                    var configuredTextField: UITextField!
                    
                    beforeEach {
                        configuredTextField = UITextField()
                        _ = configuredTextField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous onEditingBegin handler") {
                        let events: TextFieldEvents<String> = textFieldEvents {
                            $0.onEditingBegin = { text in "NewMessage!: \(text)" }
                            $0.onEditingChanged = { text in "onEditingChanged: \(text)" }
                            $0.onEditingEnd = { text in "onEditingEnd: \(text)" }
                        }
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.onEvents(events)])
                        let result = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredTextField.sendActions(for: .editingDidBegin)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("NewMessage!: Hello World"))
                    }
                    
                    it("replaces the previous onEditingChanged handler") {
                        let events: TextFieldEvents<String> = textFieldEvents {
                            $0.onEditingBegin = { text in "onEditingBegin: \(text)" }
                            $0.onEditingChanged = { text in "NewMessage!: \(text)" }
                            $0.onEditingEnd = { text in "onEditingEnd: \(text)" }
                        }
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.onEvents(events)])
                        let result = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredTextField.sendActions(for: .editingChanged)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("NewMessage!: Hello World"))
                    }
                    
                    it("replaces the previous onEditingEnd handler") {
                        let events: TextFieldEvents<String> = textFieldEvents {
                            $0.onEditingBegin = { text in "onEditingBegin: \(text)" }
                            $0.onEditingChanged = { text in "onEditingChanged: \(text)" }
                            $0.onEditingEnd = { text in "NewMessage!: \(text)" }
                        }
                        let newChangeSet = TextFieldChangeSet<String>(properties: [.onEvents(events)])
                        let result = configuredTextField.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredTextField.sendActions(for: .editingDidEnd)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("NewMessage!: Hello World"))
                    }
                    
                }
                
                context("when the change set contains textField stylesheet changes") {
                    
                    it("applies 'textColor' property changes") {
                        let textField = UITextField()
                        _ = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(textField.textColor).to(equal(.red))
                    }
                    
                    it("applies 'alignment' property changes") {
                        let textField = UITextField()
                        _ = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(textField.textAlignment).to(equal(NSTextAlignment.center))
                    }
                    
                    it("applies 'textFont' and 'textSize' property changes") {
                        let textField = UITextField()
                        _ = textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                        expect(textField.font).to(equal(UIFont(name: "Helvetica", size: 12)))
                    }
                    
                }
                
            }
            
        }
        
    }
}
