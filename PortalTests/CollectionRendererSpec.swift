//
//  CollectionRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/8/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class CollectionRendererSpec: QuickSpec {
    
    typealias ActionType = Action<MockRoute, String>
    typealias CustomComponentRenderer = VoidCustomComponentRenderer<String, MockRoute>
    typealias PortalCollection = PortalCollectionView<String, MockRoute, CustomComponentRenderer>
    
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        var collection: PortalCollection!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
            collection = PortalCollectionView(layoutEngine: layoutEngine) {
                VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
            }
        }
        
        describe(".apply(changeSet: CollectionChangeSet) -> Result") {
            
            var changeSet: CollectionChangeSet<ActionType>!
            
            beforeEach {
                let itemPropertie: CollectionItemProperties<ActionType> = collectionItem(onTap: .sendMessage("onTap!"), identifier: "identifier)") {
                    return container()
                }
                
                let collectionProperties: CollectionProperties<ActionType> = properties(itemsWidth: 150, itemsHeight: 150) {
                    $0.items = [itemPropertie, itemPropertie]
                    $0.showsVerticalScrollIndicator = true
                    $0.showsHorizontalScrollIndicator = false
                    $0.minimumInteritemSpacing = 10
                    $0.minimumLineSpacing = 5
                    $0.scrollDirection = .horizontal
                    $0.sectionInset = SectionInset(top: 10, left: 20, bottom: 30, right: 40)
                }
                
                changeSet = CollectionChangeSet.fullChangeSet(
                    properties: collectionProperties,
                    style: styleSheet(),
                    layout: layout()
                )
            }
            
            context("when the change set contains collection property changes") {
                
                it("applies 'items' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(collection.collectionView(collection, numberOfItemsInSection: 0)).to(equal(2))
                }
                
                it("applies 'showsVerticalScrollIndicator' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(collection.showsVerticalScrollIndicator).to(beTrue())
                }
                
                it("applies 'showsHorizontalScrollIndicator' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(collection.showsHorizontalScrollIndicator).to(beFalse())
                }
             
                it("applies 'minimumInteritemSpacing' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.minimumInteritemSpacing).to(equal(10))
                }
                
                it("applies 'minimumLineSpacing' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.minimumLineSpacing).to(equal(5))
                }
                
                it("applies 'scrollDirection' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.scrollDirection).to(equal(UICollectionViewScrollDirection.horizontal))
                }
                
                it("applies 'sectionInset' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.sectionInset).to(equal(UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)))
                }
                
                it("applies 'sectionInset' property changes") {
                    _ = collection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.itemSize).to(equal(CGSize(width: 150, height: 150)))
                }
                
                context("when the items are already configured") {
                    
                    var configuredCollection: PortalCollection!
                    
                    beforeEach {
                        configuredCollection = PortalCollectionView(layoutEngine: layoutEngine) {
                            VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
                        }
                        _ = configuredCollection.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("replaces the previous items") {
                        let newChangeSet = CollectionChangeSet<ActionType>(properties: [CollectionProperties.Property.items([])])
                        _ = configuredCollection.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        
                        expect(configuredCollection.collectionView(configuredCollection, numberOfItemsInSection: 0)).to(equal(0))
                    }
                    
                }
                
            }
            
        }
        
    }
}
