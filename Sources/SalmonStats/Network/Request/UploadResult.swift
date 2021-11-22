//
//  Rotation.swift
//  
//
//  Created by tkgstrator on 2021/04/17.
//

import Foundation
import Alamofire
import SplatNet2
import SwiftyJSON

public class UploadResult: RequestType {
    public typealias ResponseType = [UploadResult.Response]
    
    public var method: HTTPMethod = .post
    public var path: String = "results"
    public var encoding: ParameterEncoding = JSONEncoding.default
    public var parameters: Parameters?
    public var headers: [String : String]?
    
    init(results: [Result.Response]) {
        self.parameters = ["results": results]
    }
    
    init(result: Result.Response) {
        self.parameters = ["results": [result.asJSON()]]
    }

    public struct Response: Codable {
        var created: Bool
        var jobId: Int
        var salmonId: Int
    }
}

extension Result.Response {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted, .sortedKeys]
        return encoder
    }()
    
    func asJSON() -> [String: Any] {
        guard let data = try? Result.Response.encoder.encode(self) else {
            return [:]
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return [:]
        }
        return json
    }
}
