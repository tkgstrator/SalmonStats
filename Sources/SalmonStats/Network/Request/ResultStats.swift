//
//  ResultStats.swift
//  
//
//  Created by tkgstrator on 2021/04/13.
//

import Foundation
import Alamofire
import SplatNet2

public class ResultStats: RequestType {
    public typealias ResponseType = ResultStats.Response
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(resultId: Int) {
        self.path = "results/\(resultId)"
    }
    
    public struct Response: Codable {
        public var bossAppearanceCount: Int
        public var bossAppearances: [Int: Int]
        public var bossEliminationCount: Int
        public var clearWaves: Int
        public var createdAt: String
        public var dangerRate: String
        public var failReasonId: Int?
        public var goldenEggDelivered: Int
        public var id: Int
        public var isEligibleForNoNightRecord: Bool
        public var memberAccounts: [CrewMember]?
        public var members: [String]
        public var playerResults: [PlayerResult]
        public var powerEggCollected: Int
        public var schedule: ShiftRecord.Response.Schedule?
        public var scheduleId: String
        public var startAt: String
        public var updatedAt: String
        public var uploaderUserId: Int
        public var waves: [WaveResult]
        
        public struct CrewMember: Codable {
            public var id: Int?
            public var isCustomName: Bool?
            public var isPrimary: Int?
            public var isRegistered: Bool?
            public var name: String
            public var playerId: String
            public var twitterAvatar: String?
            public var updatedAt: String?
            public var userId: Int?
        }
        
        public struct PlayerResult: Codable {
            public var bossEliminationCount: Int
            public var bossEliminations: Elimination
            public var death: Int
            public var goldenEggs: Int
            public var gradePoint: Int?
            public var playerId: String
            public var powerEggs: Int
            public var rescue: Int
            public var specialId: Int
            public var specialUses: [SpecialUsage]
            public var weapons: [Weapon]
            
            public struct Elimination: Codable {
                public var counts: [Int: Int]
            }
            
            public struct SpecialUsage: Codable {
                public var count: Int
            }
            
            public struct Weapon: Codable {
                public var weaponId: Int
            }
        }
        
        public struct WaveResult: Codable {
            public var eventId: Int
            public var goldenEggAppearances: Int
            public var goldenEggDelivered: Int
            public var goldenEggQuota: Int
            public var powerEggCollected: Int
            public var waterId: Int
            public var wave: Int
        }
    }
}
