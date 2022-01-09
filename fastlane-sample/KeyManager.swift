//
//  KeyManager.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import Foundation

struct KeyManager {

    private let keyFilePath = Bundle.main.path(forResource: "key", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
