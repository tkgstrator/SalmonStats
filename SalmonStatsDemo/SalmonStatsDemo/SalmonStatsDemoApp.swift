//
//  SalmonStatsDemoApp.swift
//  SalmonStatsDemo
//
//  Created by tkgstrator on 2021/04/14.
//  
//

import SwiftUI
import SalmonStats
import SplatNet2

@main
struct SalmonStatsDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SalmonStats(userAgent: "SalmonStats/@tkgling"))
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        if let manager = LogManager.shared {
            #if DEBUG
            manager.logLevel = .debug
            #else
            manager.logLevel = .info
            #endif
        }
        return true
    }
}
