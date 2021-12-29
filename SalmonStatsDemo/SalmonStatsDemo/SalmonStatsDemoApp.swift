//
//  SalmonStatsDemoApp.swift
//  SalmonStatsDemo
//
//  Created by tkgstrator on 2021/04/14.
//  
//

import SwiftUI
import SalmonStats

@main
struct SalmonStatsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SalmonStats(userAgent: "SalmonStats/@tkgling"))
        }
    }
}
