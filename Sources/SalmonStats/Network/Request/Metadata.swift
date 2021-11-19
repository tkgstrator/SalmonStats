//
//  Metadata.swift
//  
//
//  Created by tkgstrator on 2021/07/09.
//

import Foundation
import Alamofire
import SplatNet2

public class Metadata: RequestType {
    public typealias ResponseType = [Metadata.Response]
    
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    public var encoding: ParameterEncoding = URLEncoding.default
    
    init(nsaid: String) {
        self.path = "metadata"
    }
    
    // MARK: - Metadata
    public struct Response: Codable {
        public let user: User
        public let schedules: [Schedule]
    }

    // MARK: - Schedule
    public struct Schedule: Codable {
        public let scheduleId, endAt: String
        public let weapons: [Int]
        public let stageId: Int
        public let rareWeaponId: Int?
    }

    // MARK: - User
    public struct User: Codable {
        public let id: Int
        public let name: String
        public let twitterAvatar: String
        public let updatedAt: String
        public let isCustomName, isRegistered: Bool
        public let accounts: [Account]
    }

    // MARK: - Account
    public struct Account: Codable {
        public let userId: Int
        public let playerId: String
        public let isPrimary: Bool
        public let name: Name
    }

    // MARK: - Name
    public struct Name: Codable {
        public let playerId, name, createdAt, updatedAt: String
    }
}
