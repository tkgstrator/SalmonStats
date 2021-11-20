//
//  Player.swift
//  
//
//  Created by devonly on 2021/11/20.
//

import Foundation
import Alamofire
import SplatNet2

public class Player: RequestType {
    public typealias ResponseType = [Player.Response]
    
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    public var encoding: ParameterEncoding = URLEncoding.default
    
    init(nsaid: String) {
        self.path = "players/metadata"
        self.parameters = ["ids": nsaid]
    }

    // MARK: - Response
    public struct Response: Codable {
        public let name: String
        public let isRegistered, isCustomName: Int
        public let twitterAvatar: String
        public let playerId: String
        public let total: Total
        public let results: Results
    }

    // MARK: - Results
    public struct Results: Codable {
        public let clear, fail: Int
    }

    // MARK: - Total
    public struct Total: Codable {
        public let goldenEggs, powerEggs, rescue, death: Int
        public let bossEliminationCount: Int
    }
}
