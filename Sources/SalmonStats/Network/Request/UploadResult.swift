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
    
    public var method: HTTPMethod = .post
    public var path: String = "results"
    public var encoding: ParameterEncoding = JSONEncoding.default
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(results: [[String: Any]]) {
        self.parameters = ["results": results]
    }

    public struct Response: Codable {
        var created: Bool
        var jobId: Int
        var salmonId: Int
    }
}
