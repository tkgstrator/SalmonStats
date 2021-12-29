//
//  Keychain.swift
//  
//
//  Created by devonly on 2021/12/29.
//  
//

import Foundation
import KeychainAccess
import SplatNet2

public enum KeyType: String, CaseIterable {
    case apiToken
}

extension Keychain {
    func setValue(_ value: String, key: KeyType) {
        try? set(value, key: key.rawValue)
    }

    func getValue(key: KeyType) throws -> String {
        guard let value = try? get(key.rawValue) else { throw SP2Error.dataDecodingFailed }
        return value
    }
}
