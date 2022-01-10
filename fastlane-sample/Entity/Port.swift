//
//  Port.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum PortType {
    case normal
    case highPaymentRate
    case lowPaymentRate
    case destination
    case disable
    case availableKickboard
    case irregularCycle // kickboard専用ポートなのにcycleが置かれている
    case irregularKickboard // cycle専用ポートなのにkickboardが置かれている
}

enum LocatableDeviceType {
    case cycle
    case kickboard
    case all
}

struct Port: Codable, Equatable {
    let name: String
    let location: GeoPoint
}
