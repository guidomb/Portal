//
//  MapViewRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import MapKit

internal struct MapViewRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: MapProperties
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let mapView = PortalMapView()
        let changeSet = MapViewChangeSet.fullChangeSet(properties: properties, style: style, layout: layout)
        
        return mapView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension PortalMapView: MessageForwarder {
    
    func apply<MessageType>(changeSet: MapViewChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension PortalMapView {
    
    fileprivate func apply(changeSet: [MapProperties.Property]) {
        for property in changeSet {
            
            switch property {
                
            case .center(let coordinates):
               self.mapCenter = coordinates
            
            case .isScrollEnabled(let isScrollEnabled):
                self.isScrollEnabled = isScrollEnabled
            
            case .isZoomEnabled(let isZoomEnabled):
                self.isZoomEnabled = isZoomEnabled
                
            case .placemarks(let placemarks):
                self.placemarks = placemarks
                
            case .zoomLevel(let zoomLevel):
                self.zoomLevel = zoomLevel
            }
        }
    }
    
}
