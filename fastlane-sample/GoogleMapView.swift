//
//  GoogleMapView.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    typealias UIViewType = GMSMapView
        
    var manager : CLLocationManager = CLLocationManager()
    
    let mapView: GMSMapView
    let onSelectPort: (Port) -> Void
    let onUpdateIndicatorArea: (GeoPoint, Double) -> Void
    
    init(mapView: GMSMapView, onSelectPort: @escaping (Port) -> Void, onUpdateIndicatorArea: @escaping (GeoPoint, Double) -> Void) {
        self.mapView = mapView
        self.onSelectPort = onSelectPort
        self.onUpdateIndicatorArea = onUpdateIndicatorArea
    }
        
    func makeCoordinator() -> GoogleMapsView.Coordinator {
        return Coordinator(mapView: self)
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        manager.delegate = context.coordinator
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {}
    
    func moveAnimate(location: GeoPoint) {
        let coodinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let camera = GMSCameraPosition.camera(withTarget: coodinate, zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: 0)
        mapView.animate(to: camera)
    }
}

extension GoogleMapsView {
    class Coordinator: NSObject, CLLocationManagerDelegate, GMSMapViewDelegate {
        
        var parent: GoogleMapsView
        
        init(mapView: GoogleMapsView) {
            parent = mapView
            let zoomLevel = 16
            let camera = GMSCameraPosition.camera(withLatitude: 35.70328194230664, longitude: 139.47924412504977, zoom: Float(zoomLevel))
            parent.mapView.camera = camera
        }
        
        var initialized: Bool = false
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse: break
            case .notDetermined, .denied, .restricted: break
            @unknown default: break
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location: CLLocation = locations.last!
            print("Location: \(location)")
            
            if !initialized {
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
                parent.mapView.camera = camera
                initialized = true
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            manager.stopUpdatingLocation()
            print("Error: \(error)")
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let port = marker.userData as? Port else {
                return false
            }
            parent.onSelectPort(port)
            parent.moveAnimate(location: port.location)
            return true
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            let center = mapView.projection.coordinate(for: mapView.convert(CGPoint(x: mapView.center.x, y: mapView.center.y), from: mapView))
            let top = mapView.projection.coordinate(for: mapView.convert(CGPoint(x: mapView.frame.size.width / 2.0, y: 0), from: mapView))
            parent.onUpdateIndicatorArea(.init(latitude: center.latitude, longitude: center.longitude), center.distance(from: top))
        }
    }
}
