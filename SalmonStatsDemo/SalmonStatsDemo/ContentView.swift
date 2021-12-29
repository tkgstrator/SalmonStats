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
//import BetterSafariView
import SplatNet2

struct ContentView: View {
    @EnvironmentObject var service: SalmonStats
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
                        .authorize(isPresented: $isPresented[0], manager: service as SplatNet2) { completion in
                            print(completion)
                        }
                    Button(action: { service.revokeIksmSession() }, label: {
                        Text("Revoke IksmSession")
                    })
                    Button(action: { isPresented[1].toggle() }, label: {
                        Text("Salmon Stats")
                    })
                        .authorizeToken(isPresented: $isPresented[1], manager: service) { completion in
                            print(completion)
                        }
                    
                }, header: {
                    Text("Authorize")
                })
                Section(content: {
                    Button(action: {
                        service.getMetadata(nsaid: "91d160aa84e88da6")
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
                        service.getPlayerMetadata(nsaid: "91d160aa84e88da6")
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
                        service.uploadResult(resultId: 3585)
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
                        service.uploadResults(resultId: 3590)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response.first)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("UPLOAD RESULTS")
                    })
                    Button(action: {
                        service.getResult(resultId: 1000000)
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
                        service.getResults(pageId: 1)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response.count)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET RESULTS(PAGE)")
                    })
                    Button(action: {
                        service.getResults(from: 1, to: 2)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response.count)
                            })
                            .store(in: &task)
                    }, label: {
                        Text("GET RESULTS(PAGES)")
                    })
                }, header: {
                    Text("Salmon Stats")
                })
                Section(content: {
                    Button(action: {
                        service.getCoopResult(resultId: 3580)
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
                        service.getCoopResults(resultId: 3585)
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { response in
                                print(response.count)
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
                    Text(service.account?.credential.nsaid)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("iksm_session")
                    Spacer()
                    Text(service.account?.credential.iksmSession)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("api-token")
                    Spacer()
                    Text(service.apiToken)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("x-product version")
                    Spacer()
                    Text(service.version)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("jobNum")
                    Spacer()
                    Text(service.account?.coop.jobNum)
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
