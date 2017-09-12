//
//  CarouselRendererSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/8/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class CarouselRendererSpec: QuickSpec {
    
    typealias ActionType = Action<MockRoute, String>
    typealias CustomComponentRenderer = VoidCustomComponentRenderer<String, MockRoute>
    typealias PortalCarousel = PortalCarouselView<String, MockRoute, CustomComponentRenderer>
    
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        var carousel: PortalCarousel!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
            let renderer = UIKitComponentRenderer(layoutEngine: layoutEngine) {
                VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
            }
            carousel = PortalCarouselView(renderer: renderer)
        }
        
        describe(".apply(changeSet: CarouselChangeSet) -> Result") {
            
            var changeSet: CarouselChangeSet<ActionType>!
            
            beforeEach {
                let item: CarouselItemProperties<ActionType> = carouselItem(onTap: .sendMessage("OnTap!"), identifier: "identifier") {
                    container()
                }
                
                let carouselProperties: CarouselProperties<ActionType> = properties(
                    itemsWidth: 450,
                    itemsHeight: 150,
                    items: ZipList(of: [item, item], selected: 1)!
                ) {
                    $0.isSnapToCellEnabled = true
                    $0.minimumInteritemSpacing = 5
                    $0.minimumLineSpacing = 10
                    $0.onSelectionChange = { _ in .sendMessage("onSelectionChange") }
                    $0.sectionInset = SectionInset(top: 10, left: 20, bottom: 30, right: 40)
                    $0.showsScrollIndicator = true
                }
                
                changeSet = CarouselChangeSet.fullChangeSet(properties: carouselProperties, style: styleSheet(), layout: layout())
            }
            
            context("when the change set contains carousel property changes") {
                
                it("applies 'items' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(carousel.collectionView(carousel, numberOfItemsInSection: 0)).to(equal(2))
                }
                
                it("applies 'itemsSize' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = carousel.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.itemSize).to(equal(CGSize(width: 450, height: 150)))
                }
                
                it("applies 'isSnapToCellEnabled' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(carousel.isSnapToCellEnabled).to(beTrue())
                }
                
                it("applies 'minimumInteritemSpacing' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = carousel.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.minimumInteritemSpacing).to(equal(5))
                }
                
                it("applies 'minimumLineSpacing' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = carousel.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.minimumLineSpacing).to(equal(10))
                }
                
                it("applies 'onSelectionChange' property changes") { waitUntil { done in
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    carousel.mailbox.subscribe { message in
                        switch message {
                            
                        case .sendMessage(let value):
                            expect(value).to(equal(("onSelectionChange")))
                            done()
                            
                        default:
                            fail()
                        }
                    }
                    
                    var aPoint: CGPoint = CGPoint(x:0, y:0)
                    let scrollView: UIScrollView = carousel
                    scrollView.contentOffset = CGPoint(x: -1, y: 0)
                    carousel.scrollViewWillEndDragging(carousel, withVelocity: aPoint, targetContentOffset: &aPoint)
                }}
                
                it("applies 'sectionInset' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let layout = carousel.collectionViewLayout as! UICollectionViewFlowLayout
                    expect(layout.sectionInset).to(equal(UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)))
                }
                
                it("applies 'showsScrollIndicator' property changes") {
                    _ = carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(carousel.showsHorizontalScrollIndicator).to(beTrue())
                }
                
                // TODO: This test is crashing
//                context("when the items are already configured") {
//
//                    var configuredCarousel: PortalCarousel!
//
//                    beforeEach {
//                        configuredCarousel = PortalCarouselView(layoutEngine: layoutEngine) {
//                            VoidCustomComponentRenderer<String, MockRoute>(container:  MockContainerController())
//                        }
//                        _ = configuredCarousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
//                    }
//
//                    it("replaces the previous items") {
//                        let newChangeSet = CarouselChangeSet<ActionType>(properties: [CarouselProperties.Property.items(.none)])
//                        _ = configuredCarousel.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
//                        expect(configuredCarousel.collectionView(configuredCarousel, numberOfItemsInSection: 0)).to(equal(0))
//                    }
//
//                }
                
            }
        }
        
    }
}
