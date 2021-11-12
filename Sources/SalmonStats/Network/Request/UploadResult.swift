//
//  Rotation.swift
//  
//
//  Created by tkgstrator on 2021/04/17.
//

import Foundation
import Alamofire
import SplatNet2

public class UploadResult: RequestType {
    public typealias ResponseType = [UploadResult.Response]
    public var baseURL: URL = URL(string: "https://salmon-stats-api.yuki.games/api/")!
    public var method: HTTPMethod = .post
    public var path: String = "results"
    public var encoding: ParameterEncoding = JSONEncoding.default
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(accessToken: String, results: [[String: Any]]) {
        self.headers = ["Authorization": "Bearer \(accessToken)"]
        self.parameters = ["results": results]
    }

    public struct Response: Codable {
        public var created: Bool
        public var jobId: Int
        public var salmonId: Int
    }
}
