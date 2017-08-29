//
//  TextViewRenderSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 8/28/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class TextViewRenderSpec: QuickSpec {
    override func spec() {
    
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: TextViewChangeSet) -> Result") {
        
            var changeSet: TextViewChangeSet!
            
            beforeEach {
                let textViewStyle = textViewStyleSheet { base, textView in
                    textView.textColor = .red
                    textView.textFont = Font(name: "Helvetica")
                    textView.textSize = 12
                    textView.textAligment = .center
                }
                
                changeSet = TextViewChangeSet.fullChangeSet(
                    textType: .regular("This is a textView!"),
                    style: textViewStyle,
                    layout: layout())
            }
            
            context("when the change set contains textType changes") {
            
                it("applies 'text' property changes") {
                    let textView = UITextView()
                    let _: Render<String> = textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textView.text).to(equal("This is a textView!"))
                }
                
                it("applies 'attributedText' property changes") {
                    let textViewStyle = textViewStyleSheet { base, textView in
                        textView.textColor = .red
                        textView.textFont = Font(name: "Helvetica")
                        textView.textSize = 12
                        textView.textAligment = .center
                    }
                    
                    changeSet = TextViewChangeSet.fullChangeSet(
                        textType: .attributed(NSAttributedString(string: "This is a textView!")),
                        style: textViewStyle,
                        layout: layout()
                    )
                    
                    let textView = UITextView()
                    let _: Render<String> = textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    expect(textView.attributedText.string).to(equal("This is a textView!"))
                }
                
                
                // TODO: Check NSAttributedString's attributes
            }
            
            context("when the change set contains textView stylesheet changes") {
                
                it("applies 'textColor' property changes") {
                    let textView = UITextView()
                    let _: Render<String> = textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textView.textColor).to(equal(.red))
                }
                
                it("applies 'textFont' and 'textSize' property changes") {
                    let textView = UITextView()
                    let _: Render<String> = textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textView.font).to(equal(UIFont(name: "Helvetica", size: 12)))
                }
                
                it("applies 'textAligment' property changes") {
                    let textView = UITextView()
                    let _: Render<String> = textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(textView.textAlignment).to(equal(NSTextAlignment.center))
                }
                
            }
            
        }
        
    }
}
