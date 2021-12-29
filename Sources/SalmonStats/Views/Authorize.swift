//
//  Authorize.swift
//  SalmonStats
//
//  Created by devonly on 2021/10/19.
//

import SwiftUI
import SplatNet2
import BetterSafariView
import Combine

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    let manager: SalmonStats
    
    public typealias CompletionHandler = (Swift.Result<String, SP2Error>) -> Void
    let completionHandler: CompletionHandler
    
    public init(isPresented: Binding<Bool>, manager: SalmonStats, completionHandler: @escaping CompletionHandler) {
        self._isPresented = isPresented
        self.completionHandler = completionHandler
        self.manager = manager
    }
    
    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented, content: {
                WebAuthenticationSession(url: URL(unsafeString: "https://salmon-stats-api.yuki.games/auth/twitter"), callbackURLScheme: "salmon-stats") { callbackURL, _ in
                    if let apiToken = callbackURL?.absoluteString.capture(pattern: "api-token=(.*)", group: 1) {
                        manager.apiToken = apiToken
//                        completionHandler(.success(apiToken))
                    } else {
//                        completionHandler(.failure(.response))
                    }
                }
                .prefersEphemeralWebBrowserSession(false)
            })
    }
}

public extension View {
    func authorizeToken(isPresented: Binding<Bool>, manager: SalmonStats, completion: @escaping (Swift.Result<String, SP2Error>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented, manager: manager) { response in
            completion(response)
        })
    }
}
