//
//  TableRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
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
                let itemPropertie: TableItemProperties<ActionType> = tableItem(height: 100, onTap: .sendMessage("OnTap!"), selectionStyle: .default) { _ in
                    return TableItemRender(
                        component: container(),
                        typeIdentifier: "identifier"
                    )
                }
                
                let tableProperties: TableProperties<ActionType> = properties {
                    $0.items = [itemPropertie, itemPropertie]
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
            
        }
        
    }
}
