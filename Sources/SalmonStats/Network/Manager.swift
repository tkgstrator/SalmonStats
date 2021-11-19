//
//  Manager.swift
//  
//
//  Created by tkgstrator on 2021/04/10.
//

import Foundation
import Alamofire
import Combine
import SplatNet2
import KeychainAccess

open class SalmonStats: SplatNet2 {
    public var apiToken: String? {
        get {
            try? keychain.getValue(key: .apiToken)
        }
        set {
            if let newValue = newValue {
                keychain.setValue(newValue, key: .apiToken)
            }
        }
    }
    
    public override init(version: String = "1.13.0") {
        super.init(version: version)
    }
}

public enum KeyType: String, CaseIterable {
    case apiToken
}

extension Keychain {
    func setValue(_ value: String, key: KeyType) {
        try? set(value, key: key.rawValue)
    }
    
    func getValue(key: KeyType) throws -> String {
        guard let value = try? get(key.rawValue) else { throw SP2Error.OAuth(.response, nil) }
        return value
    }
}
