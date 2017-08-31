//
//  MapViewRenderSpec.swift
//  PortalTests
//
//  Created by Argentino Ducret on 8/29/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Quick
import Nimble
@testable import Portal

class MapViewRenderSpec: QuickSpec {
    override func spec() {
        
        var layoutEngine: LayoutEngine!
        
        beforeEach {
            layoutEngine = YogaLayoutEngine()
        }

        describe(".apply(changeSet: MapViewChangeSet) -> Result") {
            
            var changeSet: MapViewChangeSet!
            var placemarks: [MapPlacemark]!
            
            beforeEach {
                placemarks = [MapPlacemark(coordinates: Coordinates(latitude: 15, longitude: 15))]
                
                let properties = MapProperties(
                    placemarks: placemarks,
                    center: Coordinates(latitude: 10, longitude: 10),
                    isZoomEnabled: false,
                    zoomLevel: 2.5,
                    isScrollEnabled: true
                )
                
                changeSet = MapViewChangeSet.fullChangeSet(properties: properties, style: styleSheet(), layout: layout())
            }
            
            context("when the change set contains properties changes") {
                
                it("applies 'placemarks' property changes") {
                    let map = PortalMapView()
                    let _: Render<String> = map.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    let mapPlacemarks = map.annotations.map {
                        MapPlacemark(
                            coordinates: Coordinates(
                                latitude: $0.coordinate.latitude,
                                longitude: $0.coordinate.longitude
                            )
                        )
                    }
                    expect(mapPlacemarks).to(equal(placemarks))
                }
                
                it("applies 'center' property changes") {
                    let map = PortalMapView()
                    let _: Render<String> = map.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(map.mapCenter).to(equal(Coordinates(latitude: 10, longitude: 10)))
                }
                
                it("applies 'isZoomEnabled' property changes") {
                    let map = PortalMapView()
                    let _: Render<String> = map.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(map.isZoomEnabled).to(beFalse())
                }
                
                it("applies 'zoomLevel' property changes") {
                    let map = PortalMapView()
                    let _: Render<String> = map.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(map.zoomLevel).to(equal(2.5))
                }
                
                it("applies 'isScrollEnabled' property changes") {
                    let map = PortalMapView()
                    let _: Render<String> = map.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    expect(map.isScrollEnabled).to(beTrue())
                }
                
                context("when there are optional properties set to .none") {
                    
                    var configuredMap: PortalMapView!
                    
                    beforeEach {
                        configuredMap = PortalMapView()
                        let _: Render<String> = configuredMap.apply(changeSet: changeSet, layoutEngine: layoutEngine)
                    }
                    
                    it("removes the map center") {
                        let newChangeSet = MapViewChangeSet(properties: [.center(.none)])
                        let _: Render<String> = configuredMap.apply(changeSet: newChangeSet, layoutEngine: layoutEngine)
                        expect(configuredMap.mapCenter).to(beNil())
                    }
                    
                }
                
            }
            
        }
        
    }
}
