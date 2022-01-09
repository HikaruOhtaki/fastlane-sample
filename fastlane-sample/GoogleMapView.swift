//
//  GoogleMapView.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import SwiftUI
import UIKit
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    typealias UIViewType = GMSMapView
    
    @Binding var manager : CLLocationManager
    @State var preciseLocationZoomLevel: Float = 15.0
    @State var approximateLocationZoomLevel: Float = 10.0
    
    let mapView = GMSMapView(frame: CGRect.zero)
    
    func makeCoordinator() -> GoogleMapsView.Coordinator {
        return Coordinator(mapView: self)
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        manager.delegate = context.coordinator
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
        print(#function)
    }
}

extension GoogleMapsView {
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        var parent: GoogleMapsView
        
        init(mapView: GoogleMapsView) {
            parent = mapView
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
                let zoomLevel = manager.accuracyAuthorization == .fullAccuracy ? parent.preciseLocationZoomLevel : parent.approximateLocationZoomLevel
                let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
                parent.mapView.camera = camera
                initialized = true
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            manager.stopUpdatingLocation()
            print("Error: \(error)")
        }
        
        
    }
}
