//
//  Manager.swift
//  
//
//  Created by tkgstrator on 2021/04/10.
//

import Foundation
import Alamofire
import Combine
import SplatNet2
import KeychainAccess

open class SalmonStats: SplatNet2 {
    public var apiToken: String? {
        get {
            try? keychain.getValue(key: .apiToken)
        }
        set {
            if let newValue = newValue {
                keychain.setValue(newValue, key: .apiToken)
            }
        }
    }
    
    public override init(version: String = "1.13.2") {
        super.init(version: version)
    }
    
    public func getMetadata(nsaid: String) -> AnyPublisher<[Metadata.Response], SP2Error> {
        let request = Metadata(nsaid: nsaid)
        return publish(request)
    }
    
    public func getPlayerMetadata(nsaid: String) -> AnyPublisher<[Player.Response], SP2Error> {
        let request = Player(nsaid: nsaid)
        return publish(request)
    }
    
    public func getResult(resultId: Int) -> AnyPublisher<Result.Response, SP2Error> {
        let request = ResultStats(resultId: resultId)
        return Future { [self] promise in
            publish(request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(Result.Response(from: response, playerId: account.nsaid)))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    override open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        if let url = urlRequest.url?.absoluteString {
            if url.contains("salmon-stats") {
                guard let apiToken = apiToken else {
                    completion(.failure(SP2Error.OAuth(.code, nil)))
                    return
                }
                // Salmon Stats
                var urlRequest = urlRequest
                urlRequest.headers.add(.userAgent("Salmonia3/tkgling"))
                urlRequest.headers.add(.authorization(bearerToken: apiToken))
                completion(.success(urlRequest))
            } else {
                // SplatNet2
                var urlRequest = urlRequest
                urlRequest.headers.add(.userAgent("Salmonia3/tkgling"))
                urlRequest.headers.add(HTTPHeader(name: "cookie", value: "iksm_session=\(iksmSession)"))
                completion(.success(urlRequest))
            }
        } else {
            completion(.failure(SP2Error.Common(.unavailable, nil)))
        }
    }
    
    override open func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}

public enum KeyType: String, CaseIterable {
    case apiToken
}

extension Keychain {
    func setValue(_ value: String, key: KeyType) {
        try? set(value, key: key.rawValue)
    }
    
    func getValue(key: KeyType) throws -> String {
        guard let value = try? get(key.rawValue) else { throw SP2Error.OAuth(.response, nil) }
        return value
    }
}
