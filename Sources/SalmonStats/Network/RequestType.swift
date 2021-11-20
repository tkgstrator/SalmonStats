//
//  Protocol.swift
//  
//
//  Created by tkgstrator on 2021/04/10.
//

import Foundation
import Alamofire
import SplatNet2

public extension RequestType {
    var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }
    
    var headers: [String: String]? {
        nil
    }

    var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(30)

        if let params = parameters {
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
