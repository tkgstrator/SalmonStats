//
//  ShiftRecord.swift
//  
//
//  Created by tkgstrator on 2021/04/13.
//

import Foundation
import Alamofire
import SplatNet2

public class ShiftRecord: RequestType {
    public typealias ResponseType = ShiftRecord.Response
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(startTime: Int) {
        self.path = "schedules/\(startTime)"
    }
    
    public struct Response: Codable {
        public var records: Record
        public var results: [Result]
        public var schedule: Schedule
        
        public struct Record: Codable {
            public var noNightTotals: TotalRecord
            public var totals: TotalRecord
            public var waveRecords: WaveRecord
            
            public struct TotalRecord: Codable {
                public var goldenEggs: Total
                public var powerEggs: Total
                
                public struct Total: Codable {
                    public var id: Int
                    public var goldenEggs: Int
                    public var powerEggs: Int
                    public var members: [String]
                }
            }
            
            public struct WaveRecord: Codable {
                public var goldenEgigs: [Wave]
                public var powerEggs: [Wave]
                
                public struct Wave: Codable {
                    public var eventId: Int
                    public var goldenEggs: Int
                    public var id: Int
                    public var members: [String]
                    public var powerEggs: Int
                    public var waterId: Int
                }
            }
        }
        
        public struct Result: Codable {
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
            public var members: [String]
            public var powerEggCollected: Int
            public var scheduleId: String
            public var startAt: String
            public var updatedAt: String
            public var uploaderUserId: Int
        }
        
        public struct Schedule: Codable {
            public var endAt: String
            public var rareWeaponId: Int?
            public var scheduleId: String
            public var stageId: Int
            public var weapons: [Int]
        }
    }
}
