//
//  MapScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum MapScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        let placemarks = [
            MapPlacemark(coordinates: Coordinates(latitude: 10, longitude: 10), icon: .localImage(named: "placemark")),
            MapPlacemark(coordinates: Coordinates(latitude: 15, longitude: 15), icon: .localImage(named: "placemark")),
            MapPlacemark(coordinates: Coordinates(latitude: 20, longitude: 20), icon: .localImage(named: "placemark"))
        ]
        let properties = MapProperties(
            placemarks: placemarks,
            center: Coordinates(latitude: 15, longitude: 15),
            isZoomEnabled: true,
            zoomLevel: 1.0,
            isScrollEnabled: true
        )
        
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Map")),
            component: container(
                children: [
                    mapView(
                        properties: properties,
                        style: styleSheet {
                            $0.backgroundColor = .green
                        },
                        layout: layout {
                            $0.flex = flex() { $0.grow = .one }
                        }
                    )
                ],
                style: styleSheet {
                    $0.backgroundColor = .black
                },
                layout: layout {
                    $0.flex = flex() { $0.grow = .one }
                }
            )
        )
    }
    
}

