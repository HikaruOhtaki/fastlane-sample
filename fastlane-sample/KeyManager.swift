//
//  KeyManager.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2022/01/09.
//

import Foundation

class KeyManager {

    static func getKeys() -> NSDictionary? {
        guard let keyFilePath = Bundle.main.path(forResource: "key", ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    static func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
