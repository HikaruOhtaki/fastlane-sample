//
//  PortRepository.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

protocol PortRepository {
    func getPort(portId: String) async throws -> Port?
    func getPorts() async throws -> [Port]
}

class PortRepositoryImpl: PortRepository {
    private let db = Firestore.firestore()

    func getPort(portId: String) async throws -> Port? {
        let portRef = db.collection("ports").document(portId)
        let document = try await portRef.getDocument()
        let port = try document.data(as: Port.self)
        return port
    }
    
    func getPorts() async throws -> [Port] {
        let portRef = db.collection("ports")
        let snapshot = try await portRef.getDocuments()
        let ports = snapshot.documents.compactMap { try? $0.data(as: Port.self) }
        return ports
    }
}
