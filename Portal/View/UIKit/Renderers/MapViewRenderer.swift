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
        let mapView = PortalMapView(placemarks: properties.placemarks)
        
        mapView.isZoomEnabled = properties.isZoomEnabled
        if let center = properties.center {
            let span = MKCoordinateSpanMake(properties.zoomLevel, properties.zoomLevel)
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                span: span
            )
            mapView.setRegion(region, animated: true)
        }
        mapView.isScrollEnabled = properties.isScrollEnabled
        
        mapView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: mapView)
        
        return Render(view: mapView)
    }
    
}
