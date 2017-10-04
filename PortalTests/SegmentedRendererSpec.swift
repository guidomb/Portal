//
//  SegmentedRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class SegmentedRendererSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }
        
        describe(".apply(changeSet: SegmentedChangeSet) -> Result") {
            
            var changeSet: SegmentedChangeSet<String>!
            
            beforeEach {
                let segments = ZipList(element: segment(title: "test", onTap: "Tapped!", isEnabled: true))
                
                let style = segmentedStyleSheet { base, segmented in
                    segmented.borderColor = .red
                    segmented.textColor = .blue
                    segmented.textFont = Font(name: "Helvetica")
                    segmented.textSize = 15
                }
                
                changeSet = SegmentedChangeSet.fullChangeSet(
                    segments: segments,
                    style: style,
                    layout: layout()
                )
            }
            
            context("when the change set contains segmented property changes") {
                
                it("applies 'title' property changes") {
                    let segmented = UISegmentedControl()
                    _ = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(segmented.titleForSegment(at: 0)).to(equal("test"))
                }
                
                it("applies 'onTap' property changes") { waitUntil { done in
                    let segmented = UISegmentedControl()
                    let result = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    result.mailbox?.subscribe {
                        expect($0).to(equal("Tapped!"))
                        done()
                    }
                    
                    segmented.sendActions(for: .valueChanged)
                }}
                
                it("applies 'isEnabled' property changes") {
                    let segmented = UISegmentedControl()
                    _ = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(segmented.isEnabledForSegment(at: 0)).to(beTrue())
                }
                
                context("when there are optional properties set to .none") {
                    
                    var configuredSegmented: UISegmentedControl!
                    
                    beforeEach {
                        configuredSegmented = UISegmentedControl()
                        _ = configuredSegmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("removes the segmented's on tap handler") {
                        let segmentProperties: SegmentProperties<String> = segment(title: "test", isEnabled: true)
                        let segments = ZipList(element: segmentProperties)
                        let newChangeSet = SegmentedChangeSet<String>(segments: .change(to: segments))
                        let result = configuredSegmented.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        result.mailbox?.subscribe { _ in fail("On tap handler was not removed") }
                        
                        configuredSegmented.sendActions(for: .valueChanged)
                    }
                    
                }
                
                context("when an on tap handler is already configured") {
                    
                    var configuredSegmented: UISegmentedControl!
                    
                    beforeEach {
                        configuredSegmented = UISegmentedControl()
                        _ = configuredSegmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous on tap handler") {
                        let segmentProperties: SegmentProperties<String> = segment(title: "test", onTap: "NewMessage!", isEnabled: true)
                        let segments = ZipList(element: segmentProperties)
                        let newChangeSet = SegmentedChangeSet<String>(segments: .change(to: segments))
                        let result = configuredSegmented.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        // We need reference semantics to avoid copies inside mailbox's subscribe
                        // closure in order to assert that the expected messages were received.
                        let receivedMessages = NSMutableArray()
                        result.mailbox?.subscribe { receivedMessages.add($0) }
                        
                        configuredSegmented.sendActions(for: .valueChanged)
                        
                        expect(receivedMessages.count).to(equal(1))
                        expect(receivedMessages.firstObject as? String).to(equal("NewMessage!"))
                    }
                    
                }
                
            }
            
            context("when the change set contains segmented stylesheet changes") {
                
                it("applies 'borderColor' property changes") {
                    let segmented = UISegmentedControl()
                    _ = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(segmented.tintColor).to(equal(.red))
                }
                
                it("applies 'textColor' property changes") {
                    let segmented = UISegmentedControl()
                    _ = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    let attributes = segmented.titleTextAttributes(for: .normal)!
                    let color = attributes[NSAttributedStringKey.foregroundColor] as! UIColor
                    expect(color).to(equal(UIColor.blue))
                }
                
                it("applies 'textFont' and 'textSize' property changes") {
                    let segmented = UISegmentedControl()
                    _ = segmented.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    let attributes = segmented.titleTextAttributes(for: .normal)!
                    let font = attributes[NSAttributedStringKey.font] as! UIFont
                    expect(font).to(equal(UIFont(name: "Helvetica", size: 15)))
                }
                
            }

        }
        
    }
}
