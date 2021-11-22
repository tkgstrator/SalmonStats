//
//  ResultsStats.swift
//  
//
//  Created by tkgstrator on 2021/04/13.
//

import Foundation
import Alamofire
import SplatNet2

public class ResultsStats: RequestType {
    public typealias ResponseType = ResultsStats.Response
    
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String : String]?
    public var encoding: ParameterEncoding = URLEncoding.default
    
    init(nsaid: String, pageId: Int, count: Int = 50) {
        self.parameters = [
            "raw": 0,
            "count": count,
            "page": pageId
        ]
        self.path = "players/\(nsaid)/results"
    }
    
    public struct Response: Codable {
        public let currentPage: Int
        public let from, lastPage: Int
        public let to, total: Int
        public let results: [Result.Response]
    }
}
