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
import CocoaLumberjackSwift

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
    
    public func getMetadata(nsaid: String) -> AnyPublisher<[Metadata.Response], SP2Error> {
        let request = Metadata(nsaid: nsaid)
        return publish(request)
    }
    
    public func getPlayerMetadata(nsaid: String) -> AnyPublisher<[Player.Response], SP2Error> {
        let request = Player(nsaid: nsaid)
        return publish(request)
    }
    
    public func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error> {
        Future { [self] promise in
            getCoopResult(resultId: resultId)
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .flatMap({ publish(UploadResult(result: $0)) })
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(response))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    public func uploadResults(resultId: Int) -> AnyPublisher<[(UploadResult.Response, Result.Response)], SP2Error> {
        var results: [Result.Response] = []
        return Future { [self] promise in
            getCoopResults()
                .flatMap({ response -> Publishers.Sequence<[[Result.Response]], Never> in
                    results = response
                    return response.chunked(by: 10).publisher
                })
                .flatMap({ publish(UploadResult(results: $0)) })
//                .replaceError(with: UploadResult.ResponseType())
                .collect()
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    let salmonstats = response.flatMap({ $0 }).sorted(by: { $0.jobId < $1.jobId })
                    promise(.success(zip(salmonstats, results).map({ ($0.0, $0.1) })))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    public func getResults(from: Int, to: Int) -> AnyPublisher<[Result.Response], SP2Error> {
        Future { [self] promise in
            (from ... to).publisher
                .flatMap(maxPublishers: .max(1), { getResults(pageId: $0) })
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .collect()
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in
                    promise(.success(response.flatMap({ $0 })))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    public func getResults(pageId: Int, count: Int = 50) -> AnyPublisher<[Result.Response], SP2Error> {
        guard let nsaid = account?.credential.nsaid else {
            return Fail(outputType: [Result.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = ResultsStats(nsaid: nsaid, pageId: pageId, count: count)
        return Future { [self] promise in
            publish(request)
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in
                    promise(.success(response.results.map({ Result.Response(from: $0, playerId: nsaid) })))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    public func getResult(resultId: Int) -> AnyPublisher<Result.Response, SP2Error> {
        guard let nsaid = account?.credential.nsaid else {
            return Fail(outputType: Result.Response.self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = ResultStats(resultId: resultId)
        return Future { [self] promise in
            publish(request)
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(Result.Response(from: response, playerId: nsaid)))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
    
    open override func publish<T>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> where T : RequestType {
        return session
            .request(request, interceptor: self)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .mapError({ error -> SP2Error in
                DDLogError(error)
                guard let sp2Error = error.asSP2Error else {
                    return SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: error.responseCode ?? 999), failure: nil)
                }
                return sp2Error
            })
            .eraseToAnyPublisher()
    }
    
    open override func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        guard let apiToken = apiToken else {
            completion(.failure(SP2Error.dataDecodingFailed))
            return
        }
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: apiToken))
        completion(.success(urlRequest))
    }
}
