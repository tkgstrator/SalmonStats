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
        self.parameters = ["ids": nsaid]
        self.path = "players/metadata"
    }
    
    public struct Response: Codable {
        public var isCustomName: Int
        public var isRegistered: Int
        public var name: String
        public var playerId: String
        public var results: Result
        public var total: Total
        public var twitterAvatar: String?
        
        public struct Result: Codable {
            public var clear: Int
            public var fail: Int
        }
        
        public struct Total: Codable {
            public var bossEliminationCount: Int
            public var death: Int
            public var goldenEggs: Int
            public var powerEggs: Int
            public var rescue: Int
        }
    }
}
