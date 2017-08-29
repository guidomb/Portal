//
//  MapView.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/18/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import UIKit
import MapKit

fileprivate let mapViewAnnotationIdentifier = "PortalMapViewAnnotation"

internal final class PortalMapView: MKMapView {
    
    internal var placemarks: [MapPlacemark] = [] {
        didSet {
            for placemark in placemarks {
                let annotation = MapPlacemarkAnnotation(placemark: placemark)
                self.addAnnotation(annotation)
                self._placemarks[annotation] = placemark
            }
        }
    }
    
    internal var zoomLevel: Double = 1.0 {
        didSet {
            setCenter()
        }
    }
    
    internal var mapCenter: Coordinates? = .none {
        didSet {
            setCenter()
        }
    }
    
    fileprivate var _placemarks: [MapPlacemarkAnnotation : MapPlacemark] = [:]
    
    init() {
        super.init(frame: CGRect.zero)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PortalMapView: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            let annotation = annotation as? MapPlacemarkAnnotation,
            let placemark = placemark(for: annotation)
        else { return .none }
        
        let annotationView = dequeueReusableAnnotationView(for: annotation)
        annotationView.image = placemark.icon?.asUIImage
        
        return annotationView
    }
    
}

fileprivate extension PortalMapView {
    
    fileprivate func placemark(for annotation: MapPlacemarkAnnotation) -> MapPlacemark? {
        return _placemarks[annotation]
    }
    
    fileprivate func dequeueReusableAnnotationView(for annotation: MapPlacemarkAnnotation) -> MKAnnotationView {
        if let annotationView = dequeueReusableAnnotationView(withIdentifier: mapViewAnnotationIdentifier) {
            return annotationView
        } else {
            return MKAnnotationView(annotation: annotation, reuseIdentifier: mapViewAnnotationIdentifier)
        }
    }
    
    fileprivate func setCenter() {
        if let center = mapCenter {
            let span = MKCoordinateSpanMake(zoomLevel, zoomLevel)
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                span: span
            )
            setRegion(region, animated: true)
        }
    }
    
}

fileprivate final class MapPlacemarkAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(placemark: MapPlacemark) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: placemark.coordinates.latitude,
            longitude: placemark.coordinates.longitude
        )
    }
    
}
