//
//  TableRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
import UIKit
@testable import Portal

class TableRendererSpec: QuickSpec {
    
    typealias ActionType = Action<MockRoute, String>
    typealias CustomComponentRenderer = VoidCustomComponentRenderer<String, MockRoute>
    typealias PortalTable = PortalTableView<String, MockRoute, CustomComponentRenderer>
    
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        var table: PortalTable!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
            table = PortalTableView(renderer: UIKitComponentRenderer(layoutEngine: layoutEngine) {
                VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
            })
        }
        
        describe(".apply(changeSet: TableChangeSet) -> Result") {
            
            var changeSet: TableChangeSet<ActionType>!
            
            beforeEach {
                let itemProperties: TableItemProperties<ActionType> = tableItem(height: 100, onTap: .sendMessage("OnTap!"), selectionStyle: .default) { _ in
                    return TableItemRender(
                        component: container(),
                        typeIdentifier: "identifier"
                    )
                }
                
                let tableProperties: TableProperties<ActionType> = properties {
                    $0.items = [itemProperties, itemProperties]
                    $0.showsVerticalScrollIndicator = true
                    $0.showsHorizontalScrollIndicator = false
                }
                
                let style = tableStyleSheet { base, table in
                    table.separatorColor = .red
                }
                
                changeSet = TableChangeSet.fullChangeSet(
                    properties: tableProperties,
                    style: style,
                    layout: layout()
                )
            }
            
            context("when the change set contains table property changes") {
                
                it("applies 'items' property changes") {
                    _ = table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(table.tableView(table, numberOfRowsInSection: 1)).to(equal(2))
                }
                
                it("applies 'showsVerticalScrollIndicator' property changes") {
                    _ = table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(table.showsVerticalScrollIndicator).to(beTrue())
                }
                
                it("applies 'showsHorizontalScrollIndicator' property changes") {
                    _ = table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(table.showsHorizontalScrollIndicator).to(beFalse())
                }
                
                context("when the items are already configured") {
                    
                    var configuredTable: PortalTable!
                    
                    beforeEach {
                        configuredTable = PortalTableView(renderer: UIKitComponentRenderer(layoutEngine: layoutEngine) {
                            VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
                        })
                        _ = configuredTable.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous items") {
                        let newChangeSet = TableChangeSet<ActionType>(properties: [TableProperties.Property.items([])])
                        _ = configuredTable.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)

                        expect(configuredTable.tableView(configuredTable, numberOfRowsInSection: 1)).to(equal(0))
                    }
                    
                }
                
            }
            
            context("when the change set contains table stylesheet changes") {
                
                it("applies 'separatorColor' property changes") {
                    _ = table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    
                    expect(table.separatorColor).to(equal(.red))
                }
                
            }
            
            context("when a button is rendered inside a table item and cells are reused after applying a change set") {
                
                beforeEach {
                    let tableProperties: TableProperties<ActionType> = properties {
                        $0.items = self.buildTableItemsWithButton(buttonTitle: "Tap Me!", cellsCount: 2)
                        $0.showsVerticalScrollIndicator = true
                        $0.showsHorizontalScrollIndicator = false
                    }
                    
                    let style = tableStyleSheet { base, table in
                        table.separatorColor = .red
                    }
                    
                    changeSet = TableChangeSet.fullChangeSet(
                        properties: tableProperties,
                        style: style,
                        layout: layout()
                    )
                }
                
                it("removes all mailbox bindings") {
                    // We need an NSArray to be able to reference it and mutate
                    // it inside escaping closures passed to mailbox's subscribe
                    // method in order to stored all sent events.
                    let receivedActions = NSMutableArray()
                    
                    // Render a table from a full table change set
                    _ = table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    table.mailbox.subscribe(subscriber: receivedActions.add)
                    
                    // Find the first button inside the first cell
                    // and send a touchUpInside event to simulate a user
                    // tapping on the button. An event should be send
                    // through the table's mailbox.
                    guard let firstButton = self.findUIButton(
                        withTitle: "Tap Me!",
                        withinTable: table,
                        atCell: 0) else {
                        fail("First button cannot be found")
                        return
                    }
                    firstButton.sendActions(for: .touchUpInside)
                    
                    expect(receivedActions.count).to(equal(1))
                    
                    // Create a new table change set to update the table's item list
                    // This simulates how a table gets updated every time a new render
                    // cycle is executed
                    let newItemProperties = self.buildTableItemsWithButton(
                        buttonTitle: "Tap Me! 2",
                        cellsCount: 2
                    )
                    let newChangeSet = TableChangeSet(
                        properties: [.items(newItemProperties)],
                        baseStyleSheet: [],
                        tableStyleSheet: [],
                        layout: []
                    )
                    _ = table.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                    
                    // Find the first new button inside the first cell
                    // and send a touchUpInside event to simulate a user
                    // tapping on the button. Only one event should be send
                    // through the table's mailbox.
                    guard let secondButton = self.findUIButton(
                        withTitle: "Tap Me! 2",
                        withinTable: table,
                        atCell: 0) else {
                            fail("Second button cannot be found")
                            return
                    }
                    secondButton.sendActions(for: .touchUpInside)
                    
                    // If this expectation fails, it means that
                    // more events are being dispatched to the table's mailbox
                    // than it should. Which means that there maybe be cell's mailbox
                    // that are being binded more than once after cell reuse
                    expect(receivedActions.count).to(equal(2))
                }
                
            }
            
        }
        
    }
}

fileprivate extension UIView {
    
    func findUIButtonWith(title: String) -> UIButton? {
        if let button = self as? UIButton, button.titleLabel?.text == title {
            return button
        } else {
            return subviews.lazy
                .flatMap { $0.findUIButtonWith(title: title) }
                .first
        }
    }
    
}

fileprivate extension TableRendererSpec {
    
    fileprivate func buildTableItemsWithButton(
        buttonTitle: String,
        cellsCount: UInt) -> [TableItemProperties<ActionType>] {
        let cellHeight = UInt(50)
        return (0 ..< cellsCount).map { _ in
            return tableItem(height: cellHeight, onTap: .sendMessage("OnTap!"), selectionStyle: .default) { _ in
                return TableItemRender(
                    component: container(
                        children:[
                            button(text: buttonTitle, onTap: .sendMessage("Button '\(buttonTitle)' tapped"))
                        ],
                        layout: layout() {
                            $0.height = Dimension(value: cellHeight)
                        }
                    ),
                    typeIdentifier: "identifier"
                )
            }
        }
    }
    
    fileprivate func findUIButton(
        withTitle title: String,
        withinTable table: UITableView,
        atCell index: Int) -> UIButton? {
        guard let cell = table.cellForRow(at: IndexPath(row: index, section: 0)) else {
            return .none
        }
        guard let button = cell.findUIButtonWith(title: title) else {
            return .none
        }
        return button
    }

}

