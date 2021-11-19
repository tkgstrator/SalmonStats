//
//  Protocol.swift
//  
//
//  Created by tkgstrator on 2021/04/10.
//

import Foundation
import Alamofire
import SplatNet2

extension RequestType {
    public var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }

    public var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    public func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(20)

        if let params = parameters {
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
