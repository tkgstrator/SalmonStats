//
//  ResultStats.swift
//  
//
//  Created by tkgstrator on 2021/04/13.
//

import Foundation
import Alamofire
import SplatNet2

public class Result: RequestType {
    public typealias ResponseType = Result.Response
    
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(resultId: Int) {
        self.path = "results/\(resultId)"
    }
    
    // MARK: - Result
    public struct Response: Codable {
        public let id: Int
        public let scheduleId, startAt: String
        public let members: [String]
        public let bossAppearances: [String: Int]
        public let uploaderUserId, clearWaves: Int
        public let failReasonId: Int?
        public let dangerRate, createdAt, updatedAt: String
        public let goldenEggDelivered, powerEggCollected, bossAppearanceCount, bossEliminationCount: Int
        public let isEligibleForNoNightRecord: Bool
        public let memberAccounts: [MemberAccount]
        public let schedule: Schedule
        public let playerResults: [PlayerResult]
        public let waves: [Wave]
    }

    // MARK: - MemberAccount
    public struct MemberAccount: Codable {
        public let playerId, name: String
        public let id: Int?
        public let twitterAvatar: String?
        public let updatedAt: String?
        public let userId, isPrimary: Int?
        public let isCustomName, isRegistered: Bool?
    }

    // MARK: - PlayerResult
    public struct PlayerResult: Codable {
        public let playerId: String
        public let goldenEggs, powerEggs, rescue, death: Int
        public let specialId, bossEliminationCount: Int
        public let gradePoint: Int?
        public let bossEliminations: BossEliminations
        public let specialUses: [SpecialUs]
        public let weapons: [Weapon]
    }

    // MARK: - BossEliminations
    public struct BossEliminations: Codable {
        public let counts: [String: Int]
    }

    // MARK: - SpecialUs
    public struct SpecialUs: Codable {
        public let count: Int
    }

    // MARK: - Weapon
    public struct Weapon: Codable {
        public let weaponId: Int
    }

    // MARK: - Schedule
    public struct Schedule: Codable {
        public let scheduleId, endAt: String
        public let weapons: [Int]
        public let stageId: Int
        public let rareWeaponId: Int?
    }

    // MARK: - Wave
    public struct Wave: Codable {
        public let wave, eventId, waterId, goldenEggQuota: Int
        public let goldenEggAppearances, goldenEggDelivered, powerEggCollected: Int

    }
}
