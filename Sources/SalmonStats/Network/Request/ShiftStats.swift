//
//  File.swift
//  
//
//  Created by tkgstrator on 2021/04/13.
//

import Foundation
import Alamofire
import SplatNet2

public class ShiftStats: RequestType {
    public typealias ResponseType = ShiftStats.Response
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(startTime: Int) {
        self.path = "players/91d160aa84e88da6/schedules/\(startTime)"
    }
    
    public struct Response: Codable {
        // グローバルのみ対応
        var global: TmpStats
        struct TmpStats: Codable {
            var bossAppearance3: Int
            var bossAppearance6: Int
            var bossAppearance9: Int
            var bossAppearance12: Int
            var bossAppearance13: Int
            var bossAppearance14: Int
            var bossAppearance15: Int
            var bossAppearance16: Int
            var bossAppearance21: Int
            var bossAppearanceCount: Int
            var bossElimination3: Int
            var bossElimination6: Int
            var bossElimination9: Int
            var bossElimination12: Int
            var bossElimination13: Int
            var bossElimination14: Int
            var bossElimination15: Int
            var bossElimination16: Int
            var bossElimination21: Int
            var bossEliminationCount: Int
            var clearGames: Int
            var clearWaves: Int
            var games: Int
            var goldenEggs: Int
            var powerEggs: Int
            var rescue: Int
        }
    }
}
