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
    @State private var task = Set<AnyCancellable>()
    @State private var isPresented: [Bool] = Array(repeating: false, count: 2)
    @State private var SP2Error: SP2Error?
    
    var body: some View {
        NavigationView(content: {
            Form(content: {
                Section(content: {
                    Button(action: { isPresented[0].toggle() }, label: {
                        Text("SplatNet2")
                    })
                        .authorize(isPresented: $isPresented[0], manager: salmonstats) { completion in
                            print(completion)
                        }
                    Button(action: { isPresented[1].toggle() }, label: {
                        Text("Salmon Stats")
                    })
                        .authorizeToken(isPresented: $isPresented[1], manager: salmonstats) { completion in
                            print(completion)
                        }
                    
                }, header: {
                    Text("Authorize")
                })
                Section(content: {
                    Button(action: {
                        salmonstats.getMetadata(nsaid: "91d160aa84e88da6")
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET METADATA")
                    })
                    Button(action: {
                        salmonstats.getPlayerMetadata(nsaid: "91d160aa84e88da6")
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET PLAYER METADATA")
                    })
                    
                }, header: {
                    Text("Metadata")
                })
                Section(content: {
                    Button(action: {
                        salmonstats.uploadResult(resultId: 3590)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("UPLOAD RESULT")
                    })
                    Button(action: {
                        salmonstats.getResult(resultId: 1000000)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET RESULT")
                    })
                    Button(action: {
                        salmonstats.getResults(nsaid: salmonstats.account.nsaid, pageId: 1)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET RESULTS")
                    })
                }, header: {
                    Text("Salmon Stats")
                })
                Section(content: {
                    Button(action: {
                        salmonstats.getCoopResult(resultId: 3590)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET RESULT")
                    })
                    Button(action: {
                        salmonstats.getCoopResults(resultId: 3580)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response)
                            })
                            .store(in: &task)
                        
                    }, label: {
                        Text("GET RESULTS")
                    })
                }, header: {
                    Text("SplatNet2")
                })
            })
                .navigationTitle("Salmon Stats Demo")
            Form(content: {
                HStack(content: {
                    Text("nsaid")
                    Spacer()
                    Text(salmonstats.account.nsaid)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("iksm_session")
                    Spacer()
                    Text(salmonstats.account.iksmSession.prefix(16))
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("api-token")
                    Spacer()
                    Text(salmonstats.apiToken == nil ? "" : salmonstats.apiToken!.prefix(16))
                        .foregroundColor(.secondary)
                })
            })
                .navigationTitle("User")
            
        })
            .alert(item: $SP2Error) { error in
                Alert(title: Text("ERROR"), message: Text(error.localizedDescription))
            }
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
