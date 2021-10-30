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
    
    internal var keychain: Keychain
    internal let service: String = "Salmonia3/@tkgling"
    
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
    
    public init(version: String = "1.13.0") {
        keychain = Keychain(service: service)
        super.init(userAgent: service, version: version)
    }
    
    @discardableResult
    public func uploadResults(accessToken: String, results: [[String: Any]]) -> Future<[UploadResult.Response], APIError> {
        let request = UploadResult(accessToken: accessToken, results: results)
        return remote(request: request)
    }

    @discardableResult
    public func getResult(resultId: Int) -> Future<SplatNet2.Coop.Result, APIError> {
        let request = ResultStats(resultId: resultId)
        return Future { [self] promise in
            remote(request: request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { (response: ResultStats.Response) in
                    let result = SplatNet2.Coop.Result(from: response, playerId: account.nsaid)
                    promise(.success(result))
                })
                .store(in: &task)
        }
    }
    
    @discardableResult
    public func getResults(nsaid: String, pageId: Int, count: Int = 50) -> Future<[SplatNet2.Coop.Result], APIError> {
        let request = ResultsStats(nsaid: nsaid, pageId: pageId, count: count)
        
        return Future { [self] promise in
            remote(request: request)
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.global())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { (response: ResultsStats.Response) in
                    let results: [SplatNet2.Coop.Result] = response.results.map{ SplatNet2.Coop.Result(from: $0, playerId: account.nsaid) }
                    promise(.success(results))
                })
                .store(in: &task)
        }
    }
    
//    @discardableResult
    public func getAllResults(nsaid: String, promise: @escaping (Result<[SplatNet2.Coop.Result], APIError>) -> Void) {
        let request = Metadata(nsaid: nsaid)
        var results: [SplatNet2.Coop.Result] = []
        
        remote(request: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { response in
                guard let response = response.first else { return }
                #if DEBUG
                let totalResultsNum: Int = 400
                #else
                let totalResultsNum: Int = response.results.clear + response.results.fail
                #endif
                NotificationCenter.default.post(name: SalmonStats.imported, object: Progress(maxValue: totalResultsNum, currentValue: 0))
                let pageIds: [Int] = Array(Range(1 ... totalResultsNum / 200 + 1).map({ $0 }))
                pageIds.publisher
                    .subscribe(on: DispatchQueue.global())
                    .receive(on: DispatchQueue.global())
                    .flatMap(maxPublishers: .max(1), { self.getResults(nsaid: nsaid, pageId: $0, count: 200).eraseToAnyPublisher() })
                    .retry(2)
                    .timeout(.seconds(30), scheduler: DispatchQueue.global(), options: nil, customError: nil)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            promise(.success(results))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { response in
                        results.append(contentsOf: response)
                        NotificationCenter.default.post(name: SalmonStats.imported, object: Progress(maxValue: totalResultsNum, currentValue: results.count))
                    })
                    .store(in: &self.task)
            })
            .store(in: &task)
    }

    @discardableResult
    public func getMetadata(nsaid: String) -> Future<[Metadata.Response], APIError> {
        let request = Metadata(nsaid: nsaid)
        return remote(request: request)
    }

    @discardableResult
    public func getShiftStats(startTime: Int) -> Future<ShiftStats.Response, APIError> {
        let request = ShiftStats(startTime: startTime)
        return Future { [self] promise in
            publish(request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { (response: ShiftStats.Response) in
//                    let result = SalmonStats.ShiftStats(codable: response)
//                    promise(.success(result))
                })
                .store(in: &task)
        }
    }

    @discardableResult
    public func getShiftRecord(startTime: Int) -> Future<ShiftRecord.Response, APIError> {
        let request = ShiftRecord(startTime: startTime)
        return remote(request: request)
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
        guard let value = try? get(key.rawValue) else { throw APIError.nonewresults }
        return value
    }
}
