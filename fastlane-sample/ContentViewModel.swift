//
//  ContentViewModel.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import FirebaseFirestore

@MainActor
final class ContentViewModel: ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let portRepository: PortRepository
    let mapView: GMSMapView
    
    var portMarkers: [String: GMSMarker] = [:]
    var ports: [Port] = []
    var selectedPort: Port? = nil {
        didSet {
            let updatePorts = [oldValue, selectedPort].compactMap { $0 }
            updatePortMarkers(ports: updatePorts)
        }
    }
    var indicateArea: (location: GeoPoint, radius: Double)? {
        didSet {
            updateVisiblePorts()
        }
    }
    @Published var visiblePorts: [String: Port] = [:] {
        didSet {
            let newKeys = Set(visiblePorts.keys)
            let oldKeys = Set(oldValue.keys)
            
            let addingKeys = newKeys.subtracting(oldKeys)
            addPortMarkers(ports: visiblePorts.filter { addingKeys.contains($0.key) }.map { $0.value })
            
            let updatingKeys = newKeys.intersection(oldKeys)
            updatePortMarkers(ports: visiblePorts.filter { updatingKeys.contains($0.key) && $0.value != oldValue[$0.key] }.map { $0.value })
            
            let removingKeys = oldKeys.subtracting(newKeys)
            removePortMarkers(ports: oldValue.filter { removingKeys.contains($0.key) }.map { $0.value })
        }
    }
    
    init(with portRepository: PortRepository = PortRepositoryImpl(), mapView: GMSMapView) {
        self.portRepository = portRepository
        self.mapView = mapView
    }
    
    func initialize() async {
        do {
            let ports = try await portRepository.getPorts()
            self.ports = ports
            self.visiblePorts = Dictionary(uniqueKeysWithValues: ports.map { (key: $0.name, value: $0) })
        } catch let error {
            print(error)
        }
    }
    
    func setPortMarkers() {
        let ports = [Port(name: "オーケー", location: GeoPoint(latitude: 35.70520759303569, longitude: 139.48059139066248)), Port(name: "ファミマ", location: GeoPoint(latitude: 35.7029973337333, longitude: 139.4798177368975)), Port(name: "JR国分寺駅", location: GeoPoint(latitude: 35.70020051622984, longitude: 139.4797970863123))]
        self.ports = ports
        self.visiblePorts = Dictionary(uniqueKeysWithValues: ports.map { (key: $0.name, value: $0) })
    }
    
    func updateVisiblePorts() {
        // Note: 地球の円周が40_000_000m, 緯度経度はRadian 正確な値ではないが雑にやるならOK
        let locationRadius = (indicateArea?.radius ?? 1_000.0) * 360.0 / 40_000_000.0
        visiblePorts = Dictionary(
            uniqueKeysWithValues: ports
                .filter {
                    guard let indicateArea = indicateArea else {
                        return false
                    }
                    
                    return abs(indicateArea.location.longitude.distance(to: $0.location.longitude)) < locationRadius
                    && abs(indicateArea.location.latitude.distance(to: $0.location.latitude)) < locationRadius
                }
                .map { (key: $0.name, value: $0) }
        )
    }
    
    func addPortMarkers(ports: [Port]) {
        for port in ports {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: port.location.latitude, longitude: port.location.longitude)
            marker.title = port.name
            marker.appearAnimation = .pop
            marker.map = mapView
            marker.userData = port
            marker.icon = R.image.defaultPin()
            portMarkers[port.name] = marker
        }
    }
    
    func updatePortMarkers(ports: [Port]) {
        for port in ports {
            guard let marker = portMarkers[port.name] else {
                assertionFailure()
                continue
            }
            marker.position = CLLocationCoordinate2D(latitude: port.location.latitude, longitude: port.location.longitude)
            marker.title = port.name
            marker.appearAnimation = .pop
            marker.userData = port
            marker.icon = selectedPort == port ? R.image.defaultPinBig() : R.image.defaultPin()
        }
    }
    
    func removePortMarkers(ports: [Port]) {
        for port in ports {
            guard let marker = portMarkers[port.name] else {
                assertionFailure()
                continue
            }
            marker.map = nil
            portMarkers[port.name] = nil
        }
    }
    
    func setSelectedPort(port: Port) {
        self.selectedPort = port
    }
    
    func setIndicatorArea(location: GeoPoint, radius: Double) {
        self.indicateArea = (location, radius)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
