//
//  ContentView.swift
//  SalmonStatsDemo
//
//  Created by tkgstrator on 2021/04/14.
//  
//

import SwiftUI
import SalmonStats
import Combine
import BetterSafariView
import SplatNet2

let salmonstats = SalmonStats()

struct ContentView: View {
//    @State private var result: SplatNet2.Coop.Result
    @State private var task = Set<AnyCancellable>()
    @State private var isPresented: Bool = false
    @State private var SP2Error: SP2Error?
    private var queue = DispatchQueue(label: "Salmon Stats")
    
    var body: some View {
        List {
//            HStack {
//                Text("API TOKEN")
//                Spacer()
//                Text(SalmonStats.shared.apiToken ?? "-")
//            }
//            HStack {
//                Text("PID")
//                Spacer()
//                Text(SalmonStats.shared.playerId ?? "-")
//            }
//            HStack {
//                Text("SESSION")
//                Spacer()
//                Text(SplatNet2.shared.iksmSession ?? "-")
//            }
            Button(action: { isPresented.toggle() }, label: {
                Text("LOGIN")
            })
                .authorizeToken(isPresented: $isPresented, manager: salmonstats) { completion in
                print(completion)
            }
            Button(action: { getResultsFromSalmonStats() }, label: {
                Text("GET RESULTS")
            })
            Button(action: { getResultFromSalmonStats() }, label: {
                Text("GET RESULT")
            })
            .alert(item: $SP2Error) { error in
                Alert(title: Text("ERROR"), message: Text(error.localizedDescription))
            }
        }
    }
    
    private func getResultFromSalmonStats() {
        let playerId = "91d160aa84e88da6"
        salmonstats.getMetadata(nsaid: playerId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { respone in
                salmonstats.getResults(nsaid: playerId, pageId: 1)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print(error)
                        }
                    }, receiveValue: { response in
                        print(response)
                    }).store(in: &task)
            }).store(in: &task)
    }
    
    private func getResultsFromSalmonStats() {
        salmonstats.getResult(resultId: 1000000)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { response in
                print(dump(response))
            }).store(in: &task)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    private func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else { return [] }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
